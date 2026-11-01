import 'package:axscend_tech_test/journeys/albums/screens/album_photos_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/photo_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/user_albums_screen.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

/// The start page: everyone in the directory. A user's albums, an album's
/// photos and one photo open on top of it, so back returns to where you
/// were. Ids go in the path, so a deep link or a web refresh works.
@TypedGoRoute<UsersRoute>(
  path: '/users',
  routes: [
    TypedGoRoute<UserAlbumsRoute>(
      path: ':userId/albums',
      routes: [
        TypedGoRoute<AlbumPhotosRoute>(
          path: ':albumId',
          routes: [TypedGoRoute<PhotoRoute>(path: 'photos/:photoId')],
        ),
      ],
    ),
  ],
)
@immutable
class UsersRoute extends GoRouteData with $UsersRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UsersScreen();
}

/// A user's albums.
@immutable
class UserAlbumsRoute extends GoRouteData with $UserAlbumsRoute {
  const new({required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UserAlbumsScreen(userId: userId);
}

/// An album's photos.
@immutable
class AlbumPhotosRoute extends GoRouteData with $AlbumPhotosRoute {
  const new({required this.userId, required this.albumId});

  final int userId;
  final int albumId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AlbumPhotosScreen(address: (userId: userId, albumId: albumId));
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
  Widget build(BuildContext context, GoRouterState state) => PhotoScreen(
    address: (userId: userId, albumId: albumId, photoId: photoId),
  );
}
