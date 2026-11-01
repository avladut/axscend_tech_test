import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_photos.dart';
import 'package:axscend_tech_test/journeys/albums/models/user_albums.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/albums.dart';
import '../../../helpers/users.dart';

void main() {
  late MockUserRepository users;
  late MockAlbumRepository albums;
  final user = testUser(id: 7);
  final album = testAlbum(id: 3, userId: 7);
  final photos = [testPhoto(albumId: 3), testPhoto(id: 2, albumId: 3)];

  setUp(() {
    users = MockUserRepository();
    albums = MockAlbumRepository();
  });

  /// Only the last state matters here: LoadBloc's own tests cover the rest.
  LoadState<T> last<T>(LoadBloc<T> bloc) => bloc.state;

  group(UserAlbumsBloc, () {
    UserAlbumsBloc build() =>
        UserAlbumsBloc(userId: 7, users: users, albums: albums);

    blocTest<UserAlbumsBloc, LoadState<UserAlbums>>(
      'loads the user and their albums side by side',
      setUp: () {
        when(() => users.getUser(7)).thenAnswer((_) async => user);
        when(() => albums.getAlbums(userId: 7))
            .thenAnswer((_) async => [album]);
      },
      build: build,
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(
        last(bloc),
        loadedWith(UserAlbums(user: user, albums: [album])),
      ),
    );

    blocTest<UserAlbumsBloc, LoadState<UserAlbums>>(
      'passes refresh on to both',
      setUp: () {
        when(() => users.getUser(7, refresh: true))
            .thenAnswer((_) async => user);
        when(() => albums.getAlbums(userId: 7, refresh: true))
            .thenAnswer((_) async => []);
      },
      build: build,
      act: (bloc) => bloc.add(const LoadRequested(refresh: true)),
      verify: (bloc) => expect(last(bloc).status, LoadStatus.success),
    );

    blocTest<UserAlbumsBloc, LoadState<UserAlbums>>(
      'fails when the user is unknown',
      setUp: () {
        when(() => users.getUser(7))
            .thenAnswer((_) async => throw const NotFoundFailure());
        when(() => albums.getAlbums(userId: 7)).thenAnswer((_) async => []);
      },
      build: build,
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(last(bloc).failure, isA<NotFoundFailure>()),
    );
  });

  group(AlbumPhotosBloc, () {
    AlbumPhotosBloc build({int userId = 7}) =>
        AlbumPhotosBloc(address: (userId: userId, albumId: 3), albums: albums);

    setUp(() {
      when(() => albums.getAlbum(3)).thenAnswer((_) async => album);
      when(() => albums.getPhotos(3)).thenAnswer((_) async => photos);
    });

    blocTest<AlbumPhotosBloc, LoadState<AlbumPhotos>>(
      'loads the album and its photos',
      build: build,
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(
        last(bloc),
        loadedWith(AlbumPhotos(album: album, photos: photos)),
      ),
    );

    blocTest<AlbumPhotosBloc, LoadState<AlbumPhotos>>(
      "treats another user's album as not found",
      build: () => build(userId: 8),
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(last(bloc).failure, isA<NotFoundFailure>()),
    );
  });

  group(PhotoBloc, () {
    PhotoBloc build({int userId = 7, int photoId = 1}) => PhotoBloc(
      address: (userId: userId, albumId: 3, photoId: photoId),
      albums: albums,
    );

    setUp(() {
      when(() => albums.getAlbum(3)).thenAnswer((_) async => album);
      when(() => albums.getPhoto(1)).thenAnswer((_) async => photos.first);
      when(() => albums.getPhoto(9))
          .thenAnswer((_) async => testPhoto(id: 9, albumId: 4));
    });

    blocTest<PhotoBloc, LoadState<Photo>>(
      'loads the photo',
      build: build,
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(last(bloc), loadedWith(photos.first)),
    );

    blocTest<PhotoBloc, LoadState<Photo>>(
      'treats a photo from another album as not found',
      build: () => build(photoId: 9),
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(last(bloc).failure, isA<NotFoundFailure>()),
    );

    blocTest<PhotoBloc, LoadState<Photo>>(
      "treats another user's album as not found",
      build: () => build(userId: 8),
      act: (bloc) => bloc.add(const LoadRequested()),
      verify: (bloc) => expect(last(bloc).failure, isA<NotFoundFailure>()),
    );
  });
}
