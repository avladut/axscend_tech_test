import 'package:ai_review/src/diff/diff_filter.dart';
import 'package:ai_review/src/diff/diff_source.dart';
import 'package:ai_review/src/model/review_model.dart';
import 'package:ai_review/src/publish/review_publisher.dart';
import 'package:ai_review/src/review/comment_planner.dart';
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
        _log('Commit ${headSha.substring(0, 7)} was already reviewed.');
        return ReviewOutcome.alreadyReviewed;
      }
      if (last != null) {
        if (await _diffSource.isAncestor(last, headSha)) {
          since = last;
          _log('Reviewing only the commits after ${last.substring(0, 7)}.');
        } else {
          _log(
            'The last reviewed commit is no longer in this branch (rebase or '
            'force-push), so the whole PR is reviewed.',
          );
        }
      }
    }

    final files = since == null
        ? await _diffSource.pullRequestDiff(base: base, head: headSha)
        : await _diffSource.rangeDiff(from: since, to: headSha);
    final selection = _filter.select(files);
    if (selection.isEmpty) {
      _log(
        'No reviewable changes (only lockfiles, generated or platform '
        'files changed).',
      );
      return ReviewOutcome.nothingToReview;
    }
    _log('Sending ${selection.files.length} file(s) to ${_model.name}.');

    final stopwatch = Stopwatch()..start();
    final ModelReply reply;
    try {
      reply = await _model.complete(
        system: _prompts.system(),
        user: _prompts.user(
          selection: selection,
          pullRequest: pullRequest,
          incremental: since != null,
        ),
        jsonSchema: ReviewParser.schema,
      );
    } on ReviewModelException catch (error) {
      _log('Model unavailable: ${error.message}');
      await _publisher.publishUnavailable(
        reason: error.message,
        model: _model.name,
      );
      return ReviewOutcome.modelUnavailable;
    }
    stopwatch.stop();

    final review = _parser.parse(reply.text);
    final report = ReviewReport(
      review: review,
      selection: selection,
      model: _model.name,
      headSha: headSha,
      sinceSha: since,
      took: stopwatch.elapsed,
      promptTokens: reply.promptTokens,
      completionTokens: reply.completionTokens,
    );
    await _publisher.publish(report, _planner.plan(review, selection));
    return ReviewOutcome.published;
  }
}
