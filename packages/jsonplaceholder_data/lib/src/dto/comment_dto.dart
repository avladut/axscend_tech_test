import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// A comment as `/posts/{id}/comments` sends it.
class CommentDto {
  const new({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'postId': final int postId,
      'name': final String name,
      'email': final String email,
      'body': final String body,
    } =>
      CommentDto(id: id, postId: postId, name: name, email: email, body: body),
    _ => throw invalidJson('comment', json),
  };

  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment toDomain() =>
      Comment(id: id, postId: postId, name: name, email: email, body: body);
}
