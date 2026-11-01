import 'package:domain/src/failures/data_failure.dart';
import 'package:domain/src/models/todo.dart';

/// Reads todos.
///
/// Throws a [DataFailure] when it can't deliver: an [OfflineFailure], a
/// [ServerFailure] or an [UnexpectedDataFailure]. `refresh: true` skips any
/// cache and asks the backend again.
abstract interface class TodoRepository {
  /// One user's todos, or everyone's when [userId] is null. A user with no
  /// todos, or an unknown one, gives an empty list.
  Future<List<Todo>> getTodos({int? userId, bool refresh = false});
}
