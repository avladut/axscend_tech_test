import 'dart:convert';

import 'package:ai_review/ai_review.dart';
import 'package:http/http.dart' as http;

const shaA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const shaB = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const shaC = 'cccccccccccccccccccccccccccccccccccccccc';

/// A file whose diff adds [count] lines of [width] characters each, numbered
/// from [firstLine].
FileDiff addedFile(
  String path, {
  int count = 3,
  int width = 10,
  int firstLine = 1,
}) => FileDiff(
  path: path,
  lines: [
    const DiffLine(DiffLineKind.hunk, '@@ -0,0 +1 @@'),
    for (var i = 0; i < count; i++)
      DiffLine(DiffLineKind.added, 'x' * width, newLine: firstLine + i),
  ],
);

Finding finding({
  Severity severity = Severity.minor,
  String title = 'A problem',
  String detail = 'Why it matters.',
  String? file,
  int? line,
  String? suggestion,
}) => Finding(
  severity: severity,
  title: title,
  detail: detail,
  file: file,
  line: line,
  suggestion: suggestion,
);

/// An SSE response like llama.cpp's streaming `/chat/completions`.
http.StreamedResponse sseResponse(
  List<String> contentChunks, {
  Map<String, Object?>? usage,
}) {
  final events = [
    for (final chunk in contentChunks)
      jsonEncode({
        'choices': [
          {
            'delta': {'content': chunk},
          },
        ],
      }),
    if (usage != null) jsonEncode({'choices': <Object?>[], 'usage': usage}),
    '[DONE]',
  ];
  final body = events.map((event) => 'data: $event\n\n').join();
  return http.StreamedResponse(Stream.value(utf8.encode(body)), 200);
}

class FakeDiffSource implements DiffSource {
  new({
    this.headSha = shaB,
    this.files = const [],
    this.ancestors = const {},
    List<FileDiff>? rangeFiles,
  }) : rangeFiles = rangeFiles ?? files;

  final String headSha;

  /// What the whole pull request changes.
  final List<FileDiff> files;

  /// What the commits in a range change. Defaults to [files].
  final List<FileDiff> rangeFiles;

  /// Pairs `ancestor..descendant` that count as ancestry.
  final Set<String> ancestors;

  final calls = <String>[];

  @override
  Future<String> resolve(String ref) async => headSha;

  @override
  Future<bool> isAncestor(String ancestor, String descendant) async =>
      ancestors.contains('$ancestor..$descendant');

  @override
  Future<List<FileDiff>> pullRequestDiff({
    required String base,
    required String head,
  }) async {
    calls.add('pr $base...$head');
    return files;
  }

  @override
  Future<List<FileDiff>> rangeDiff({
    required String from,
    required String to,
  }) async {
    calls.add('range $from..$to');
    return rangeFiles;
  }
}

class FakeModel implements ReviewModel {
  new({
    this.answer = '{"summary": "Fine.", "findings": []}',
    this.error,
    this.answers = const [],
  });

  final String answer;
  final ReviewModelException? error;

  /// One per call, in order: an answer (`String`) or a failure
  /// (`ReviewModelException`). When set, overrides [answer] and [error].
  final List<Object> answers;

  /// Every user prompt, in order.
  final users = <String>[];

  String? lastSystem;
  String? lastUser;
  Map<String, Object?>? lastSchema;
  int calls = 0;

  @override
  String get name => 'fake-model';

  @override
  Future<ModelReply> complete({
    required String system,
    required String user,
    Map<String, Object?>? jsonSchema,
  }) async {
    calls++;
    lastSystem = system;
    lastUser = user;
    lastSchema = jsonSchema;
    users.add(user);
    if (answers.isNotEmpty) {
      final next = answers[(calls - 1).clamp(0, answers.length - 1)];
      if (next is ReviewModelException) throw next;
      return ModelReply(
        next as String,
        promptTokens: 100,
        completionTokens: 20,
      );
    }
    final failure = error;
    if (failure != null) throw failure;
    return ModelReply(answer, promptTokens: 100, completionTokens: 20);
  }
}

class RecordingPublisher implements ReviewPublisher {
  new({this.lastSha});

  final String? lastSha;
  int historyReads = 0;
  ReviewReport? report;
  List<PlannedComment>? comments;
  String? unavailableReason;
  final notes = <({String title, String detail, String? reviewedSha})>[];

  /// True when this run left something visible on the PR.
  bool get saidSomething =>
      report != null || unavailableReason != null || notes.isNotEmpty;

  @override
  Future<String?> lastReviewedSha() async {
    historyReads++;
    return lastSha;
  }

  @override
  Future<void> publish(
    ReviewReport report,
    List<PlannedComment> comments,
  ) async {
    this.report = report;
    this.comments = comments;
  }

  @override
  Future<void> publishUnavailable({
    required String reason,
    required String model,
  }) async => unavailableReason = reason;

  @override
  Future<void> publishNote({
    required String title,
    required String detail,
    String? reviewedSha,
  }) async =>
      notes.add((title: title, detail: detail, reviewedSha: reviewedSha));
}

/// Answers git commands from a table: the joined arguments → result.
class FakeGitRunner implements GitRunner {
  new(this.answers);

  final Map<String, GitResult> answers;
  final calls = <String>[];

  @override
  Future<GitResult> run(List<String> args) async {
    final key = args.join(' ');
    calls.add(key);
    for (final entry in answers.entries) {
      if (key.startsWith(entry.key)) return entry.value;
    }
    return const GitResult(1, '', 'unexpected git call');
  }
}
