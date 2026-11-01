import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/user_dto.dart';

class JsonPlaceholderUserRepository implements UserRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<User>> getUsers({bool refresh = false}) =>
      _client.get('/users', refresh: refresh, parse: _users);

  @override
  Future<ResultPage<User>> getUsersPage(
    PageRequest page, {
    UserQuery query = const UserQuery(),
    bool refresh = false,
  }) async {
    final answer = await _client.getPage(
      '/users',
      query: {
        // JSONPlaceholder counts pages from 1.
        '_page': '${page.index + 1}',
        '_limit': '${page.size}',
        if (query.isSearching) 'q': query.search,
        '_sort': switch (query.sort) {
          UserSort.nameAscending || UserSort.nameDescending => 'name',
          UserSort.company => 'company.name',
          UserSort.city => 'address.city',
        },
        '_order': query.sort == UserSort.nameDescending ? 'desc' : 'asc',
      },
      parse: _users,
      refresh: refresh,
    );
    return ResultPage(items: answer.json, total: answer.total);
  }

  @override
  Future<User> getUser(int id, {bool refresh = false}) => _client.get(
    '/users/$id',
    refresh: refresh,
    parse: (json) => UserDto.fromJson(json).toDomain(),
  );

  static List<User> _users(Object? json) =>
      parseList(json, 'user', (item) => UserDto.fromJson(item).toDomain());
}
