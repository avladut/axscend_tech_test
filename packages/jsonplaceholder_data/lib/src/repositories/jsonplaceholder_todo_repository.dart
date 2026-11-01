import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/todo_dto.dart';

class JsonPlaceholderTodoRepository implements TodoRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<Todo>> getTodos({int? userId, bool refresh = false}) =>
      _client.get(
        userId == null ? '/todos' : '/users/$userId/todos',
        refresh: refresh,
        parse: (json) => parseList(
          json,
          'todo',
          (item) => TodoDto.fromJson(item).toDomain(),
        ),
      );
}
