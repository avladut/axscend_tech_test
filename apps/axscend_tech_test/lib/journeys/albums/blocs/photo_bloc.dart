import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:domain/domain.dart';

/// The photo at [address]. A photo that isn't in that album, or an album
/// that isn't that user's, is "not found".
class PhotoBloc extends LoadBloc<Photo> {
  new({required this.address, required this._albums});

  final PhotoAddress address;
  final AlbumRepository _albums;

  @override
  Future<Photo> load({required bool refresh}) async {
    final (album, photo) = await loadBoth(
      _albums.getAlbum(address.albumId, refresh: refresh),
      _albums.getPhoto(address.photoId, refresh: refresh),
    );
    if (album.userId != address.userId || photo.albumId != album.id) {
      throw NotFoundFailure(
        detail:
            "photo ${photo.id} is not in user ${address.userId}'s "
            'album ${address.albumId}',
      );
    }
    return photo;
  }
}
