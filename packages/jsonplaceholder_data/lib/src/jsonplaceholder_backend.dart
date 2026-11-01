import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:jsonplaceholder_data/src/client/cached_json_client.dart';
import 'package:jsonplaceholder_data/src/client/http_json_client.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/client/response_store.dart';
import 'package:jsonplaceholder_data/src/repositories/jsonplaceholder_album_repository.dart';
import 'package:jsonplaceholder_data/src/repositories/jsonplaceholder_post_repository.dart';
import 'package:jsonplaceholder_data/src/repositories/jsonplaceholder_todo_repository.dart';
import 'package:jsonplaceholder_data/src/repositories/jsonplaceholder_user_repository.dart';

/// The whole JSONPlaceholder backend: an HTTP client behind a cache, and the
/// four repositories that share it. The app creates one and registers its
/// repositories, so swapping the backend is one line in the injector.
class JsonPlaceholderBackend {
  new({http.Client? httpClient, Uri? baseUrl, ResponseStore? store})
    : this.withClient(
        CachedJsonClient(
          HttpJsonClient(client: httpClient, baseUrl: baseUrl),
          store: store,
        ),
      );

  /// For tests, or a client set up differently.
  new withClient(JsonClient client)
    : users = JsonPlaceholderUserRepository(client),
      posts = JsonPlaceholderPostRepository(client),
      albums = JsonPlaceholderAlbumRepository(client),
      todos = JsonPlaceholderTodoRepository(client);

  final UserRepository users;
  final PostRepository posts;
  final AlbumRepository albums;
  final TodoRepository todos;
}
