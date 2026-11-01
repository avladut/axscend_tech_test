import 'package:domain/src/failures/data_failure.dart';
import 'package:domain/src/models/album.dart';
import 'package:domain/src/models/photo.dart';

/// Reads albums and their photos.
///
/// Every method throws a [DataFailure] when it can't deliver: an
/// [OfflineFailure], a [ServerFailure] or an [UnexpectedDataFailure], and
/// [getAlbum] also a [NotFoundFailure]. `refresh: true` skips any cache and
/// asks the backend again.
abstract interface class AlbumRepository {
  /// One user's albums, or everyone's when [userId] is null. A user with no
  /// albums, or an unknown one, gives an empty list.
  Future<List<Album>> getAlbums({int? userId, bool refresh = false});

  /// The album with [id]. Throws a [NotFoundFailure] when there is none.
  Future<Album> getAlbum(int id, {bool refresh = false});

  /// The photos in the album with [albumId]. An unknown album gives an empty
  /// list.
  Future<List<Photo>> getPhotos(int albumId, {bool refresh = false});
}
