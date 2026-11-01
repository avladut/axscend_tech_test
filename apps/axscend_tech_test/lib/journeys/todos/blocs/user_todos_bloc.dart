import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/models/todo_models.dart';
import 'package:domain/domain.dart';

/// The user with [userId] and their todos. Which ones show is the View's
/// filter: it needs no call to the backend.
class UserTodosBloc extends LoadBloc<UserTodos> {
  new({required this.userId, required this._users, required this._todos});

  final int userId;
  final UserRepository _users;
  final TodoRepository _todos;

  @override
  Future<UserTodos> load({required bool refresh}) async {
    final (user, todos) = await loadBoth(
      _users.getUser(userId, refresh: refresh),
      _todos.getTodos(userId: userId, refresh: refresh),
    );
    return UserTodos(user: user, todos: todos);
  }
}
