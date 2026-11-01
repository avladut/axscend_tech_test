import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// A post as `/posts` sends it.
class PostDto {
  const new({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'userId': final int userId,
      'title': final String title,
      'body': final String body,
    } =>
      PostDto(id: id, userId: userId, title: title, body: body),
    _ => throw invalidJson('post', json),
  };

  final int id;
  final int userId;
  final String title;
  final String body;

  Post toDomain() => Post(id: id, userId: userId, title: title, body: body);
}
