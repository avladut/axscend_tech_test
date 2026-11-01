import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/album_dto.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/photo_dto.dart';

class JsonPlaceholderAlbumRepository implements AlbumRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<Album>> getAlbums({int? userId, bool refresh = false}) async =>
      parseList(
        await _client.get(
          userId == null ? '/albums' : '/users/$userId/albums',
          refresh: refresh,
        ),
        'album',
        (json) => AlbumDto.fromJson(json).toDomain(),
      );

  @override
  Future<Album> getAlbum(int id, {bool refresh = false}) async =>
      AlbumDto.fromJson(await _client.get('/albums/$id', refresh: refresh))
          .toDomain();

  @override
  Future<List<Photo>> getPhotos(int albumId, {bool refresh = false}) async =>
      parseList(
        await _client.get('/albums/$albumId/photos', refresh: refresh),
        'photo',
        (json) => PhotoDto.fromJson(json).toDomain(),
      );

  @override
  Future<Photo> getPhoto(int id, {bool refresh = false}) async =>
      PhotoDto.fromJson(await _client.get('/photos/$id', refresh: refresh))
          .toDomain();
}
