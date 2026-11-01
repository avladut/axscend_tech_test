import 'package:equatable/equatable.dart';

/// Why a repository couldn't deliver. Repositories throw only these, whatever
/// backend is behind them.
///
/// There is no user-facing text here: the app turns each case into a
/// translated message, and a `switch` over this sealed type makes the
/// compiler check that every case is handled.
sealed class DataFailure extends Equatable implements Exception {
  const new({this.detail});

  /// Technical detail for logs. Never shown to users.
  final String? detail;

  @override
  List<Object?> get props => [detail];

  @override
  bool get stringify => true;
}

/// No connection, or the backend didn't answer in time.
final class OfflineFailure extends DataFailure {
  const new({super.detail});
}

/// What was asked for doesn't exist.
final class NotFoundFailure extends DataFailure {
  const new({super.detail});
}

/// The backend answered with an error.
final class ServerFailure extends DataFailure {
  const new(this.statusCode, {super.detail});

  /// The HTTP status code, such as 500.
  final int statusCode;

  @override
  List<Object?> get props => [statusCode, detail];
}

/// The backend's answer didn't match the model.
final class UnexpectedDataFailure extends DataFailure {
  const new({super.detail});
}
