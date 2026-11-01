import 'package:ai_review/src/diff/diff_filter.dart';
import 'package:ai_review/src/diff/diff_source.dart';
import 'package:ai_review/src/model/review_model.dart';
import 'package:ai_review/src/publish/review_publisher.dart';
import 'package:ai_review/src/review/comment_planner.dart';
import 'package:ai_review/src/review/finding.dart';
import 'package:ai_review/src/review/prompt_builder.dart';
import 'package:ai_review/src/review/review_formatter.dart';
import 'package:ai_review/src/review/review_parser.dart';

enum ReviewOutcome {
  /// A review was posted (or printed).
  published,

  /// The head commit already has a review: nothing new to say.
  alreadyReviewed,

  /// Only files that aren't reviewed changed (lockfile, platform folders…).
  nothingToReview,

  /// The model gave no usable answer; an "unavailable" note was posted.
  modelUnavailable,
}

/// Runs one review: diff → prompt → model → findings → publisher.
class ReviewService {
  new({
    required this._diffSource,
    required this._model,
    required this._publisher,
    required this._prompts,
    this._parser = const ReviewParser(),
    this._filter = const DiffFilter(),
    this._planner = const CommentPlanner(),
    void Function(String message)? log,
  }) : _log = log ?? _ignore;

  final DiffSource _diffSource;
  final ReviewModel _model;
  final ReviewPublisher _publisher;
  final PromptBuilder _prompts;
  final ReviewParser _parser;
  final DiffFilter _filter;
  final CommentPlanner _planner;
  final void Function(String message) _log;

  static void _ignore(String _) {}

  /// Token counts add up across parts; unknown if any part didn't say.
  static int? _add(int? total, int? more) =>
      total == null || more == null ? null : total + more;

  static String _short(String sha) =>
      sha.length > 7 ? sha.substring(0, 7) : sha;

  /// Up to 10 paths in backticks, then "and N more".
  static String _listPaths(Iterable<String> paths) {
    final all = paths.toList();
    final shown = all.take(10).map((path) => '`$path`').join(', ');
    return all.length > 10 ? '$shown and ${all.length - 10} more' : shown;
  }

  /// Reviews [head] against [base]. With [incremental], a later push is
  /// reviewed only from the last reviewed commit, so findings aren't
  /// repeated; a rebase or force-push falls back to the whole PR.
  Future<ReviewOutcome> run({
    required String base,
    required String head,
    PullRequestInfo? pullRequest,
    bool incremental = true,
  }) async {
    final headSha = await _diffSource.resolve(head);

    String? since;
    if (incremental) {
      final last = await _publisher.lastReviewedSha();
      if (last == headSha) {
        _log('Commit ${_short(headSha)} was already reviewed.');
        await _publisher.publishNote(
          title: 'already reviewed',
          detail:
              'Commit `${_short(headSha)}` was already reviewed above, so '
              'there is nothing new to review in this run.',
        );
        return ReviewOutcome.alreadyReviewed;
      }
      if (last != null) {
        if (await _diffSource.isAncestor(last, headSha)) {
          since = last;
          _log('Reviewing only the commits after ${_short(last)}.');
        } else {
          _log(
            'The last reviewed commit is no longer in this branch (rebase or '
            'force-push), so the whole PR is reviewed.',
          );
        }
      }
    }

    final prFiles = await _diffSource.pullRequestDiff(
      base: base,
      head: headSha,
    );
    var files = prFiles;
    var outsidePr = 0;
    if (since != null) {
      // Merging the base branch in brings its changes into the range. They
      // aren't this PR's, and GitHub refuses comments on files outside the
      // PR's diff, so only the files the PR itself changes are kept.
      final own = {for (final file in prFiles) file.path};
      final range = await _diffSource.rangeDiff(from: since, to: headSha);
      files = [
        for (final file in range)
          if (own.contains(file.path)) file,
      ];
      outsidePr = range.length - files.length;
      if (outsidePr > 0) {
        _log(
          'Skipping $outsidePr file(s) the new commits changed outside this '
          'PR, such as a merge from the base branch.',
        );
      }
    }
    final selection = _filter.select(files);
    if (selection.isEmpty) {
      final changes = since == null
          ? 'This pull request changes'
          : 'The commits since `${_short(since)}` change';
      final detail = switch (files) {
        [] when outsidePr > 0 =>
          "$changes none of this pull request's own files: only files "
              'that came from the base branch, such as in a merge.',
        [] => '$changes no files.',
        _ =>
          '$changes only files the reviewer skips (lockfiles, '
              'generated code, platform folders, binaries or deleted '
              'files): ${_listPaths(files.map((file) => file.path))}. '
              'Nothing was sent to the model.',
      };
      _log('No reviewable changes.');
      await _publisher.publishNote(
        title: 'nothing to review',
        detail: detail,
        reviewedSha: headSha,
      );
      return ReviewOutcome.nothingToReview;
    }
    final parts = selection.batches;
    final answers = <ParsedReview>[];
    final unanswered = <String>[];
    String? failure;
    int? promptTokens = 0;
    int? completionTokens = 0;
    final stopwatch = Stopwatch()..start();
    // One part after another, so the server's other slot stays free.
    for (final (index, part) in parts.indexed) {
      _log(
        parts.length == 1
            ? 'Sending ${part.length} file(s) to ${_model.name}.'
            : 'Sending part ${index + 1} of ${parts.length} '
                  '(${part.length} file(s)) to ${_model.name}.',
      );
      try {
        final reply = await _model.complete(
          system: _prompts.system(),
          user: _prompts.user(
            selection: selection,
            pullRequest: pullRequest,
            incremental: since != null,
            part: index,
          ),
          jsonSchema: ReviewParser.schema,
        );
        answers.add(_parser.parse(reply.text));
        promptTokens = _add(promptTokens, reply.promptTokens);
        completionTokens = _add(completionTokens, reply.completionTokens);
      } on ReviewModelException catch (error) {
        _log('Model unavailable for part ${index + 1}: ${error.message}');
        failure = error.message;
        unanswered.addAll(part.map((file) => file.path));
      }
    }
    stopwatch.stop();

    if (answers.isEmpty) {
      await _publisher.publishUnavailable(
        reason: failure ?? 'no answer',
        model: _model.name,
      );
      return ReviewOutcome.modelUnavailable;
    }

    final review = _parser.merge(answers);
    final report = ReviewReport(
      review: review,
      selection: selection,
      model: _model.name,
      headSha: headSha,
      sinceSha: since,
      took: stopwatch.elapsed,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      unanswered: unanswered,
    );
    await _publisher.publish(report, _planner.plan(review, selection));
    return ReviewOutcome.published;
  }
}
