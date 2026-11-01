/// The JSONPlaceholder backend: implements the `domain` repository contracts
/// over https://jsonplaceholder.typicode.com.
///
/// Swapping the backend means adding a sibling package and changing one line
/// in the app's injector. Nothing exported here exposes JSON.
library;

export 'src/client/cached_json_client.dart';
export 'src/client/http_json_client.dart';
export 'src/client/json_client.dart';
export 'src/client/response_store.dart';
export 'src/jsonplaceholder_backend.dart';
export 'src/repositories/jsonplaceholder_album_repository.dart';
export 'src/repositories/jsonplaceholder_post_repository.dart';
export 'src/repositories/jsonplaceholder_todo_repository.dart';
export 'src/repositories/jsonplaceholder_user_repository.dart';
