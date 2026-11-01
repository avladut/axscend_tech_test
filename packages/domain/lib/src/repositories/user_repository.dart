import 'package:domain/src/failures/data_failure.dart';
import 'package:domain/src/models/user.dart';

/// Reads users, the people everything else belongs to.
///
/// Every method throws a [DataFailure] when it can't deliver: an
/// [OfflineFailure], a [ServerFailure] or an [UnexpectedDataFailure], and
/// [getUser] also a [NotFoundFailure]. `refresh: true` skips any cache and
/// asks the backend again.
abstract interface class UserRepository {
  /// Everyone, in the backend's order.
  Future<List<User>> getUsers({bool refresh = false});

  /// The user with [id]. Throws a [NotFoundFailure] when there is none.
  Future<User> getUser(int id, {bool refresh = false});
}
