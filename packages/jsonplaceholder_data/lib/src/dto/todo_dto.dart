import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// A todo as `/todos` sends it.
class TodoDto {
  const new({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'userId': final int userId,
      'title': final String title,
      'completed': final bool completed,
    } =>
      TodoDto(id: id, userId: userId, title: title, completed: completed),
    _ => throw invalidJson('todo', json),
  };

  final int id;
  final int userId;
  final String title;
  final bool completed;

  Todo toDomain() =>
      Todo(id: id, userId: userId, title: title, completed: completed);
}
