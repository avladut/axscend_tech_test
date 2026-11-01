import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';

/// What the albums journey needs. Each bloc is a factory, so every screen
/// gets a fresh one for the ids in its address.
abstract final class AlbumsInjector {
  static void init() {
    getIt
      ..registerFactoryParam<UserAlbumsBloc, int, void>(
        (userId, _) =>
            UserAlbumsBloc(userId: userId, users: getIt(), albums: getIt()),
      )
      ..registerFactoryParam<AlbumPhotosBloc, AlbumAddress, void>(
        (address, _) => AlbumPhotosBloc(address: address, albums: getIt()),
      )
      ..registerFactoryParam<PhotoBloc, PhotoAddress, void>(
        (address, _) => PhotoBloc(address: address, albums: getIt()),
      );
  }
}
