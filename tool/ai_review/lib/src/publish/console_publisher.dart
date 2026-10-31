import 'package:ai_review/src/publish/review_publisher.dart';
import 'package:ai_review/src/review/comment_planner.dart';
import 'package:ai_review/src/review/review_formatter.dart';

/// `--print`: writes the review to the terminal. Keeps no history, so every
/// run reviews the whole branch.
class ConsolePublisher implements ReviewPublisher {
  const new(this._out, {this._formatter = const ReviewFormatter()});

  final StringSink _out;
  final ReviewFormatter _formatter;

  @override
  Future<String?> lastReviewedSha() async => null;

  @override
  Future<void> publish(
    ReviewReport report,
    List<PlannedComment> comments,
  ) async => _out.write(_formatter.consoleText(report, comments));

  @override
  Future<void> publishUnavailable({
    required String reason,
    required String model,
  }) async =>
      _out.writeln(_formatter.unavailableBody(reason: reason, model: model));
}
