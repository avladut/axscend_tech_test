// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$usersRoute];

RouteBase get $usersRoute => GoRouteData.$route(
  path: '/users',
  hasOverriddenOnExit: false,
  factory: $UsersRoute._fromState,
);

mixin $UsersRoute on GoRouteData {
  static UsersRoute _fromState(GoRouterState state) => const UsersRoute();

  @override
  String get location => GoRouteData.$location('/users');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
