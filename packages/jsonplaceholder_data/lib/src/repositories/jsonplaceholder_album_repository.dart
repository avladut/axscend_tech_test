import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/album_dto.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/photo_dto.dart';

class JsonPlaceholderAlbumRepository implements AlbumRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<Album>> getAlbums({int? userId, bool refresh = false}) =>
      _client.get(
        userId == null ? '/albums' : '/users/$userId/albums',
        refresh: refresh,
        parse: (json) => parseList(
          json,
          'album',
          (item) => AlbumDto.fromJson(item).toDomain(),
        ),
      );

  @override
  Future<Album> getAlbum(int id, {bool refresh = false}) => _client.get(
    '/albums/$id',
    refresh: refresh,
    parse: (json) => AlbumDto.fromJson(json).toDomain(),
  );

  @override
  Future<List<Photo>> getPhotos(int albumId, {bool refresh = false}) =>
      _client.get(
        '/albums/$albumId/photos',
        refresh: refresh,
        parse: (json) => parseList(
          json,
          'photo',
          (item) => PhotoDto.fromJson(item).toDomain(),
        ),
      );

  @override
  Future<Photo> getPhoto(int id, {bool refresh = false}) => _client.get(
    '/photos/$id',
    refresh: refresh,
    parse: (json) => PhotoDto.fromJson(json).toDomain(),
  );
}
