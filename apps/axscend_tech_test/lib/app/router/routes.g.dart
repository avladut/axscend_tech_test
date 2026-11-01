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
  routes: [
    GoRouteData.$route(
      path: ':userId/albums',
      hasOverriddenOnExit: false,
      factory: $UserAlbumsRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: ':albumId',
          hasOverriddenOnExit: false,
          factory: $AlbumPhotosRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'photos/:photoId',
              hasOverriddenOnExit: false,
              factory: $PhotoRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
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

mixin $UserAlbumsRoute on GoRouteData {
  static UserAlbumsRoute _fromState(GoRouterState state) =>
      UserAlbumsRoute(userId: int.parse(state.pathParameters['userId']!));

  UserAlbumsRoute get _self => this as UserAlbumsRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/albums',
  );

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

mixin $AlbumPhotosRoute on GoRouteData {
  static AlbumPhotosRoute _fromState(GoRouterState state) => AlbumPhotosRoute(
    userId: int.parse(state.pathParameters['userId']!),
    albumId: int.parse(state.pathParameters['albumId']!),
  );

  AlbumPhotosRoute get _self => this as AlbumPhotosRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/albums/${Uri.encodeComponent(_self.albumId.toString())}',
  );

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

mixin $PhotoRoute on GoRouteData {
  static PhotoRoute _fromState(GoRouterState state) => PhotoRoute(
    userId: int.parse(state.pathParameters['userId']!),
    albumId: int.parse(state.pathParameters['albumId']!),
    photoId: int.parse(state.pathParameters['photoId']!),
  );

  PhotoRoute get _self => this as PhotoRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/albums/${Uri.encodeComponent(_self.albumId.toString())}/photos/${Uri.encodeComponent(_self.photoId.toString())}',
  );

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
