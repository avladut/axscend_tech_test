import 'package:axscend_tech_test/journeys/albums/screens/album_photos_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/photo_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/user_albums_screen.dart';
import 'package:axscend_tech_test/journeys/posts/screens/post_screen.dart';
import 'package:axscend_tech_test/journeys/posts/screens/user_posts_screen.dart';
import 'package:axscend_tech_test/journeys/todos/screens/user_todos_screen.dart';
import 'package:axscend_tech_test/journeys/users/screens/user_profile_screen.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

/// Every page is a [MaterialPage], so it gets the platform's transition,
/// and on iOS the swipe from the left edge to go back. Left to choose,
/// go_router 18 used a page with no transition and no swipe here.
MaterialPage<void> appPage(GoRouterState state, Widget child) => MaterialPage(
  key: state.pageKey,
  name: state.name ?? state.path,
  child: child,
);

/// The start page: everyone in the directory. A user's profile opens on
/// top of it, and their albums, posts and todos on top of that, so back
/// returns to where you were. Ids go in the path, so a deep link or a web
/// refresh works.
///
/// go_router keys a page by its route pattern, so going to the same route
/// with other ids would reuse the page and its bloc. Each screen is keyed
/// by its ids instead, so new ids always get a fresh bloc.
@TypedGoRoute<UsersRoute>(
  path: '/users',
  routes: [
    TypedGoRoute<UserRoute>(
      path: ':userId',
      routes: [
        TypedGoRoute<UserAlbumsRoute>(
          path: 'albums',
          routes: [
            TypedGoRoute<AlbumPhotosRoute>(
              path: ':albumId',
              routes: [TypedGoRoute<PhotoRoute>(path: 'photos/:photoId')],
            ),
          ],
        ),
        TypedGoRoute<UserPostsRoute>(
          path: 'posts',
          routes: [TypedGoRoute<PostRoute>(path: ':postId')],
        ),
        TypedGoRoute<UserTodosRoute>(path: 'todos'),
      ],
    ),
  ],
)
@immutable
class UsersRoute extends GoRouteData with $UsersRoute {
  const new();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      appPage(state, const UsersScreen());
}

/// A user's profile: contact details, and the way to their posts, albums
/// and todos.
@immutable
class UserRoute extends GoRouteData with $UserRoute {
  const new({required this.userId});

  final int userId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      appPage(state, UserProfileScreen(key: ValueKey(userId), userId: userId));
}

/// A user's albums.
@immutable
class UserAlbumsRoute extends GoRouteData with $UserAlbumsRoute {
  const new({required this.userId});

  final int userId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      appPage(state, UserAlbumsScreen(key: ValueKey(userId), userId: userId));
}

/// An album's photos.
@immutable
class AlbumPhotosRoute extends GoRouteData with $AlbumPhotosRoute {
  const new({required this.userId, required this.albumId});

  final int userId;
  final int albumId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final address = (userId: userId, albumId: albumId);
    return appPage(
      state,
      AlbumPhotosScreen(key: ValueKey(address), address: address),
    );
  }
}

/// One photo at full size.
@immutable
class PhotoRoute extends GoRouteData with $PhotoRoute {
  const new({
    required this.userId,
    required this.albumId,
    required this.photoId,
  });

  final int userId;
  final int albumId;
  final int photoId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final address = (userId: userId, albumId: albumId, photoId: photoId);
    return appPage(
      state,
      PhotoScreen(key: ValueKey(address), address: address),
    );
  }
}

/// A user's posts.
@immutable
class UserPostsRoute extends GoRouteData with $UserPostsRoute {
  const new({required this.userId});

  final int userId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      appPage(state, UserPostsScreen(key: ValueKey(userId), userId: userId));
}

/// One post and its comments.
@immutable
class PostRoute extends GoRouteData with $PostRoute {
  const new({required this.userId, required this.postId});

  final int userId;
  final int postId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final address = (userId: userId, postId: postId);
    return appPage(state, PostScreen(key: ValueKey(address), address: address));
  }
}

/// A user's todos.
@immutable
class UserTodosRoute extends GoRouteData with $UserTodosRoute {
  const new({required this.userId});

  final int userId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      appPage(state, UserTodosScreen(key: ValueKey(userId), userId: userId));
}
