import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/user_dto.dart';

class JsonPlaceholderUserRepository implements UserRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<User>> getUsers({bool refresh = false}) async => parseList(
    await _client.get('/users', refresh: refresh),
    'user',
    (json) => UserDto.fromJson(json).toDomain(),
  );

  @override
  Future<User> getUser(int id, {bool refresh = false}) async =>
      UserDto.fromJson(await _client.get('/users/$id', refresh: refresh))
          .toDomain();
}
