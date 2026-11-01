import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

/// The start page: everyone in the directory.
@TypedGoRoute<UsersRoute>(path: '/users')
@immutable
class UsersRoute extends GoRouteData with $UsersRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UsersScreen();
}
