import 'dart:io';

import 'package:ai_review/src/diff/file_diff.dart';
import 'package:ai_review/src/diff/unified_diff_parser.dart';

/// Where the changes under review come from.
abstract interface class DiffSource {
  /// The full commit SHA that [ref] points to.
  Future<String> resolve(String ref);

  /// Whether [ancestor] is in the history of [descendant]. False when either
  /// commit is unknown, e.g. after a force-push.
  Future<bool> isAncestor(String ancestor, String descendant);

  /// The whole pull request: [head] against its merge base with [base].
  Future<List<FileDiff>> pullRequestDiff({
    required String base,
    required String head,
  });

  /// Only the commits after [from], up to [to].
  Future<List<FileDiff>> rangeDiff({required String from, required String to});
}

class GitException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'GitException: $message';
}

class GitResult {
  const new(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;
}

/// Runs git. An interface so [GitDiffSource] can be tested without a repo.
abstract interface class GitRunner {
  Future<GitResult> run(List<String> args);
}

class ProcessGitRunner implements GitRunner {
  const new({this.workingDirectory});

  final String? workingDirectory;

  @override
  Future<GitResult> run(List<String> args) async {
    final result = await Process.run(
      'git',
      args,
      workingDirectory: workingDirectory,
    );
    return GitResult(
      result.exitCode,
      result.stdout as String,
      result.stderr as String,
    );
  }
}

class GitDiffSource implements DiffSource {
  const new(this._git, {this._parser = const UnifiedDiffParser()});

  final GitRunner _git;
  final UnifiedDiffParser _parser;

  static const _diffArgs = [
    'diff',
    '--no-color',
    '--no-ext-diff',
    '--unified=3',
    '--find-renames',
  ];

  @override
  Future<String> resolve(String ref) async =>
      (await _run(['rev-parse', '--verify', '$ref^{commit}'])).trim();

  @override
  Future<bool> isAncestor(String ancestor, String descendant) async {
    final result = await _git.run([
      'merge-base',
      '--is-ancestor',
      ancestor,
      descendant,
    ]);
    return result.exitCode == 0;
  }

  @override
  Future<List<FileDiff>> pullRequestDiff({
    required String base,
    required String head,
  }) async => _parser.parse(await _run([..._diffArgs, '$base...$head']));

  @override
  Future<List<FileDiff>> rangeDiff({
    required String from,
    required String to,
  }) async => _parser.parse(await _run([..._diffArgs, '$from..$to']));

  Future<String> _run(List<String> args) async {
    final result = await _git.run(args);
    if (result.exitCode != 0) {
      throw GitException(
        'git ${args.first} failed (${result.exitCode}): ${result.stderr}',
      );
    }
    return result.stdout;
  }
}
