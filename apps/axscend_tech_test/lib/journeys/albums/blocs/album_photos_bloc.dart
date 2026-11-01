import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_photos.dart';
import 'package:domain/domain.dart';

/// An album at [address] and its photos. An album that isn't that user's is
/// "not found", so a mistyped link can't mix two users up.
class AlbumPhotosBloc extends LoadBloc<AlbumPhotos> {
  new({required this.address, required this._albums});

  final AlbumAddress address;
  final AlbumRepository _albums;

  @override
  Future<AlbumPhotos> load({required bool refresh}) async {
    final (album, photos) = await loadBoth(
      _albums.getAlbum(address.albumId, refresh: refresh),
      _albums.getPhotos(address.albumId, refresh: refresh),
    );
    if (album.userId != address.userId) {
      throw NotFoundFailure(
        detail: "album ${album.id} is not user ${address.userId}'s",
      );
    }
    return AlbumPhotos(album: album, photos: photos);
  }
}
