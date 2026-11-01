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
      path: ':userId',
      hasOverriddenOnExit: false,
      factory: $UserRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'albums',
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
        GoRouteData.$route(
          path: 'posts',
          hasOverriddenOnExit: false,
          factory: $UserPostsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':postId',
              hasOverriddenOnExit: false,
              factory: $PostRoute._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'todos',
          hasOverriddenOnExit: false,
          factory: $UserTodosRoute._fromState,
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

mixin $UserRoute on GoRouteData {
  static UserRoute _fromState(GoRouterState state) =>
      UserRoute(userId: int.parse(state.pathParameters['userId']!));

  UserRoute get _self => this as UserRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}',
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

mixin $UserPostsRoute on GoRouteData {
  static UserPostsRoute _fromState(GoRouterState state) =>
      UserPostsRoute(userId: int.parse(state.pathParameters['userId']!));

  UserPostsRoute get _self => this as UserPostsRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/posts',
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

mixin $PostRoute on GoRouteData {
  static PostRoute _fromState(GoRouterState state) => PostRoute(
    userId: int.parse(state.pathParameters['userId']!),
    postId: int.parse(state.pathParameters['postId']!),
  );

  PostRoute get _self => this as PostRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/posts/${Uri.encodeComponent(_self.postId.toString())}',
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

mixin $UserTodosRoute on GoRouteData {
  static UserTodosRoute _fromState(GoRouterState state) =>
      UserTodosRoute(userId: int.parse(state.pathParameters['userId']!));

  UserTodosRoute get _self => this as UserTodosRoute;

  @override
  String get location => GoRouteData.$location(
    '/users/${Uri.encodeComponent(_self.userId.toString())}/todos',
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
