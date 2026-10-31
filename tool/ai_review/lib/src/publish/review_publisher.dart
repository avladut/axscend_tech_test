import 'package:ai_review/src/review/comment_planner.dart';
import 'package:ai_review/src/review/review_formatter.dart';

/// Where a finished review goes.
abstract interface class ReviewPublisher {
  /// The commit the last review covered, or null when there's none (or the
  /// publisher keeps no history, like the console).
  Future<String?> lastReviewedSha();

  Future<void> publish(ReviewReport report, List<PlannedComment> comments);

  /// The model gave no usable answer for this push.
  Future<void> publishUnavailable({
    required String reason,
    required String model,
  });

  /// A run that sends nothing to the model still says so on the PR: the bot
  /// is never silent. With [reviewedSha], the note also records that commit
  /// as reviewed, so the next push is diffed from there.
  Future<void> publishNote({
    required String title,
    required String detail,
    String? reviewedSha,
  });
}

class PublishException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'PublishException: $message';
}
