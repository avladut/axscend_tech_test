import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_photos.dart';
import 'package:axscend_tech_test/journeys/albums/models/user_albums.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';

class MockAlbumRepository extends Mock implements AlbumRepository;

class MockUserAlbumsBloc extends MockBloc<LoadRequested, LoadState<UserAlbums>>
    implements UserAlbumsBloc;

class MockAlbumPhotosBloc
    extends MockBloc<LoadRequested, LoadState<AlbumPhotos>>
    implements AlbumPhotosBloc;

class MockPhotoBloc extends MockBloc<LoadRequested, LoadState<Photo>>
    implements PhotoBloc;

/// A made-up album of user [userId].
Album testAlbum({int id = 1, int userId = 1, String title = 'Holidays'}) =>
    Album(id: id, userId: userId, title: title);

/// A made-up photo in album [albumId].
Photo testPhoto({int id = 1, int albumId = 1, String title = 'A beach'}) =>
    Photo(
      id: id,
      albumId: albumId,
      title: title,
      url: Uri.parse('https://picsum.photos/seed/$id/600'),
      thumbnailUrl: Uri.parse('https://picsum.photos/seed/$id/150'),
    );

/// A loaded state holding [data].
LoadState<T> loadedWith<T>(T data) =>
    LoadState(status: LoadStatus.success, data: data);
