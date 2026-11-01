import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:domain/domain.dart';

/// What to tell the user about a failure: a short title and a sentence.
typedef FailureText = ({String title, String message});

/// Turns a [DataFailure] into words. The only place that does, so every
/// screen explains the same failure the same way.
extension DataFailureText on DataFailure {
  /// In the app's language. The switch must cover every kind of failure, so
  /// a new one won't compile until it has text here.
  FailureText describe(AppLocalizations l10n) => switch (this) {
    OfflineFailure() => (
      title: l10n.failureOfflineTitle,
      message: l10n.failureOfflineMessage,
    ),
    NotFoundFailure() => (
      title: l10n.failureNotFoundTitle,
      message: l10n.failureNotFoundMessage,
    ),
    ServerFailure(:final statusCode) => (
      title: l10n.failureServerTitle,
      message: l10n.failureServerMessage(statusCode),
    ),
    UnexpectedDataFailure() => (
      title: l10n.failureUnexpectedTitle,
      message: l10n.failureUnexpectedMessage,
    ),
  };

  /// Whether asking again could help. Something that doesn't exist won't
  /// appear on a second try.
  bool get canRetry => this is! NotFoundFailure;
}
