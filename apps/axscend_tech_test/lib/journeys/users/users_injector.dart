import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';

/// What the users journey needs. Its repository comes from the app's
/// injector.
abstract final class UsersInjector {
  static void init() {
    // A factory: each users screen gets a fresh bloc, closed with it.
    getIt.registerFactory<UsersBloc>(() => UsersBloc(repository: getIt()));
  }
}
