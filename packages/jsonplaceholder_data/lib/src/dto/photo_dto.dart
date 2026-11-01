import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// A photo as `/albums/{id}/photos` sends it. The links arrive as strings.
class PhotoDto {
  const new({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'albumId': final int albumId,
      'title': final String title,
      'url': final String url,
      'thumbnailUrl': final String thumbnailUrl,
    } =>
      PhotoDto(
        id: id,
        albumId: albumId,
        title: title,
        url: url,
        thumbnailUrl: thumbnailUrl,
      ),
    _ => throw invalidJson('photo', json),
  };

  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo toDomain() => Photo(
    id: id,
    albumId: albumId,
    title: title,
    url: _link(url),
    thumbnailUrl: _link(thumbnailUrl),
  );

  /// Only absolute links can be loaded as images.
  Uri _link(String text) => switch (Uri.tryParse(text)) {
    final Uri uri when uri.hasScheme && uri.hasAuthority => uri,
    _ => throw invalidJson('photo link', text),
  };
}
