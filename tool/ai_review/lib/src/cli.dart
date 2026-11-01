import 'dart:io';
import 'dart:isolate';

import 'package:ai_review/src/diff/diff_filter.dart';
import 'package:ai_review/src/diff/diff_source.dart';
import 'package:ai_review/src/model/openai_compatible_model.dart';
import 'package:ai_review/src/publish/console_publisher.dart';
import 'package:ai_review/src/publish/github_publisher.dart';
import 'package:ai_review/src/publish/review_publisher.dart';
import 'package:ai_review/src/review/prompt_builder.dart';
import 'package:ai_review/src/review/review_parser.dart';
import 'package:ai_review/src/review_service.dart';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;

/// Exit codes: 0 done (including "skipped" and "model unavailable"),
/// 1 git or GitHub failed, 64 wrong usage or missing configuration.
const _usageError = 64;

const defaultModel = 'qwen38-flash';

ArgParser buildArgParser() => ArgParser()
  ..addOption(
    'base',
    help:
        r'Branch or commit the PR merges into. Default: $BASE_SHA, '
        'else origin/main.',
  )
  ..addOption('head', help: r'Commit to review. Default: $HEAD_SHA, else HEAD.')
  ..addFlag(
    'print',
    negatable: false,
    help: 'Print the review here instead of posting it on GitHub.',
  )
  ..addFlag(
    'full',
    negatable: false,
    help: 'Review the whole PR, even if earlier commits were reviewed.',
  )
  ..addOption('max-findings', defaultsTo: '10')
  ..addOption('max-diff-chars', defaultsTo: '60000')
  ..addOption(
    'system-prompt',
    help: "Reviewer instructions. Default: the package's prompts/system.md.",
  )
  ..addFlag('help', abbr: 'h', negatable: false);

/// The command-line entry point, with everything from the outside world
/// passed in so it can be tested.
Future<int> runCli(
  List<String> arguments, {
  required Map<String, String> environment,
  required StringSink out,
  required StringSink err,
  http.Client? httpClient,
  GitRunner git = const ProcessGitRunner(),
}) async {
  final parser = buildArgParser();
  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (error) {
    err
      ..writeln(error.message)
      ..writeln(parser.usage);
    return _usageError;
  }
  if (args.flag('help')) {
    out
      ..writeln('Reviews a PR with a self-hosted, OpenAI-compatible model.')
      ..writeln()
      ..writeln(parser.usage)
      ..writeln()
      ..writeln(
        'Environment: AI_REVIEW_BASE_URL, AI_REVIEW_API_KEY (or '
        'AI_REVIEW_API_KEY_FILE), AI_REVIEW_MODEL.',
      )
      ..writeln(
        'On GitHub also: GITHUB_TOKEN, GITHUB_REPOSITORY, PR_NUMBER, '
        'PR_TITLE, PR_BODY.',
      );
    return 0;
  }

  final printOnly = args.flag('print');

  // Failures go to stderr and, on GitHub, also become an error annotation,
  // so they show on the run's summary page.
  void logFailure(String message) {
    err.writeln(message);
    if (!printOnly) out.writeln('::error::$message');
  }

  final maxFindings = int.tryParse(args.option('max-findings')!);
  final maxDiffChars = int.tryParse(args.option('max-diff-chars')!);
  if (maxFindings == null || maxFindings < 1 || maxDiffChars == null) {
    err.writeln('--max-findings and --max-diff-chars must be numbers.');
    return _usageError;
  }

  // Model server settings. On GitHub, missing secrets mean "not set up yet":
  // skip with a notice instead of failing the PR.
  final baseUrl = _nonEmpty(environment['AI_REVIEW_BASE_URL']);
  final apiKey =
      _nonEmpty(environment['AI_REVIEW_API_KEY']) ??
      _readKeyFile(environment['AI_REVIEW_API_KEY_FILE']);
  if (baseUrl == null || apiKey == null) {
    const message =
        'AI review is not configured: set AI_REVIEW_BASE_URL '
        'and AI_REVIEW_API_KEY (or AI_REVIEW_API_KEY_FILE).';
    if (printOnly) {
      err.writeln(message);
      return _usageError;
    }
    out.writeln('::notice::$message Skipping the review.');
    // Still say so on the PR: the bot is never silent.
    final target = _gitHubTarget(environment);
    final headSha = _nonEmpty(environment['HEAD_SHA']);
    if (target == null || headSha == null) return 0;
    final client = httpClient ?? http.Client();
    try {
      await _gitHubPublisher(target, client, headSha).publishNote(
        title: 'not configured',
        detail:
            'The `AI_REVIEW_BASE_URL` and `AI_REVIEW_API_KEY` secrets are not '
            'set on this repository, so nothing was reviewed.',
      );
      return 0;
    } on PublishException catch (error) {
      logFailure(error.message);
      return 1;
    } finally {
      if (httpClient == null) client.close();
    }
  }
  final modelName = _nonEmpty(environment['AI_REVIEW_MODEL']) ?? defaultModel;

  final systemTemplate = await _loadSystemPrompt(args.option('system-prompt'));
  if (systemTemplate == null) {
    err.writeln('Reviewer instructions (system prompt) not found.');
    return _usageError;
  }

  final client = httpClient ?? http.Client();
  try {
    final diffSource = GitDiffSource(git);
    final head =
        args.option('head') ?? _nonEmpty(environment['HEAD_SHA']) ?? 'HEAD';
    final base =
        args.option('base') ??
        _nonEmpty(environment['BASE_SHA']) ??
        'origin/main';

    final ReviewPublisher publisher;
    PullRequestInfo? pullRequest;
    if (printOnly) {
      publisher = ConsolePublisher(out);
    } else {
      final target = _gitHubTarget(environment);
      if (target == null) {
        err.writeln(
          'Posting to GitHub needs GITHUB_TOKEN, GITHUB_REPOSITORY '
          'and PR_NUMBER. Use --print to review locally.',
        );
        return _usageError;
      }
      publisher = _gitHubPublisher(
        target,
        client,
        await diffSource.resolve(head),
      );
      pullRequest = PullRequestInfo(
        title: environment['PR_TITLE'],
        description: environment['PR_BODY'],
      );
    }

    final service = ReviewService(
      diffSource: diffSource,
      model: OpenAiCompatibleModel(
        baseUrl: Uri.parse(baseUrl),
        apiKey: apiKey,
        name: modelName,
        client: client,
      ),
      publisher: publisher,
      prompts: PromptBuilder(
        systemTemplate: systemTemplate,
        maxFindings: maxFindings,
      ),
      parser: ReviewParser(maxFindings: maxFindings),
      filter: DiffFilter(maxChars: maxDiffChars),
      // Progress goes to stderr so `--print` output stays clean.
      log: err.writeln,
    );

    final outcome = await service.run(
      base: base,
      head: head,
      pullRequest: pullRequest,
      incremental: !printOnly && !args.flag('full'),
    );
    if (outcome == ReviewOutcome.modelUnavailable && !printOnly) {
      out.writeln(
        '::warning::The review model was unavailable; an '
        '"unavailable" note was posted on the PR.',
      );
    }
    return 0;
  } on GitException catch (error) {
    logFailure(error.message);
    return 1;
  } on PublishException catch (error) {
    logFailure(error.message);
    return 1;
  } finally {
    if (httpClient == null) client.close();
  }
}

/// The PR to post on, from the Actions environment. Null when incomplete.
typedef _GitHubTarget = ({
  String token,
  String repository,
  int pullNumber,
  Uri? apiBase,
});

_GitHubTarget? _gitHubTarget(Map<String, String> environment) {
  final token = _nonEmpty(environment['GITHUB_TOKEN']);
  final repository = _nonEmpty(environment['GITHUB_REPOSITORY']);
  final pullNumber = int.tryParse(environment['PR_NUMBER'] ?? '');
  if (token == null || repository == null || pullNumber == null) return null;
  final apiUrl = _nonEmpty(environment['GITHUB_API_URL']);
  return (
    token: token,
    repository: repository,
    pullNumber: pullNumber,
    apiBase: apiUrl == null ? null : Uri.parse(apiUrl),
  );
}

GitHubPublisher _gitHubPublisher(
  _GitHubTarget target,
  http.Client client,
  String headSha,
) => GitHubPublisher(
  repository: target.repository,
  pullNumber: target.pullNumber,
  headSha: headSha,
  token: target.token,
  client: client,
  apiBase: target.apiBase,
);

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _readKeyFile(String? path) {
  final file = _nonEmpty(path);
  if (file == null) return null;
  final handle = File(file);
  return handle.existsSync() ? _nonEmpty(handle.readAsStringSync()) : null;
}

/// `--system-prompt`, else `prompts/system.md` next to this package's `lib/`.
Future<String?> _loadSystemPrompt(String? path) async {
  final File file;
  if (path != null) {
    file = File(path);
  } else {
    final library = await Isolate.resolvePackageUri(
      Uri.parse('package:ai_review/ai_review.dart'),
    );
    if (library == null) return null;
    final packageRoot = File.fromUri(library).parent.parent;
    file = File('${packageRoot.path}/prompts/system.md');
  }
  return file.existsSync() ? file.readAsStringSync() : null;
}
