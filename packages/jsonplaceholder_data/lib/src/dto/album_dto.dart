import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// An album as `/albums` sends it.
class AlbumDto {
  const new({required this.id, required this.userId, required this.title});

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'userId': final int userId,
      'title': final String title,
    } =>
      AlbumDto(id: id, userId: userId, title: title),
    _ => throw invalidJson('album', json),
  };

  final int id;
  final int userId;
  final String title;

  Album toDomain() => Album(id: id, userId: userId, title: title);
}
