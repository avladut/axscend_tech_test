import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';

/// What the todos journey needs: a fresh bloc per screen, for its user.
abstract final class TodosInjector {
  static void init() {
    getIt.registerFactoryParam<UserTodosBloc, int, void>(
      (userId, _) =>
          UserTodosBloc(userId: userId, users: getIt(), todos: getIt()),
    );
  }
}
