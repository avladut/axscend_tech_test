import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(JsonPlaceholderBackend, () {
    test('wires HTTP, the cache and the four repositories together', () async {
      final requested = <String>[];
      final backend = JsonPlaceholderBackend(
        httpClient: MockClient((request) async {
          requested.add(request.url.path);
          final name = request.url.pathSegments.last;
          return http.Response(jsonEncode(fixture(name)), 200);
        }),
      );

      expect((await backend.users.getUsers()).first, leanne);
      await backend.users.getUsers();
      expect(await backend.posts.getPosts(), hasLength(2));
      expect(await backend.albums.getAlbums(), hasLength(2));
      expect(await backend.todos.getTodos(), hasLength(2));

      // The second getUsers came from the cache.
      expect(requested, ['/users', '/posts', '/albums', '/todos']);
    });

    test('withClient shares one client between the repositories', () async {
      final client = FakeJsonClient({'/users': fixture('users')});
      final backend = JsonPlaceholderBackend.withClient(client);

      await backend.users.getUsers();

      expect(client.calls.single.path, '/users');
    });
  });
}
