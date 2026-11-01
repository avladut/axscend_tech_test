import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';

/// What the users journey needs. Its repository comes from the app's
/// injector.
abstract final class UsersInjector {
  static void init() {
    // A factory: each users screen gets a fresh bloc, closed with it.
    getIt
      ..registerFactory<UsersBloc>(() => UsersBloc(repository: getIt()))
      // A factory per user: each profile gets a fresh bloc for its id.
      ..registerFactoryParam<UserProfileBloc, int, void>(
        (userId, _) => UserProfileBloc(
          userId: userId,
          users: getIt(),
          posts: getIt(),
          albums: getIt(),
          todos: getIt(),
        ),
      );
  }
}
