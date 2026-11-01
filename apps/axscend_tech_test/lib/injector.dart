import 'package:axscend_tech_test/journeys/albums/albums_injector.dart';
import 'package:axscend_tech_test/journeys/posts/posts_injector.dart';
import 'package:axscend_tech_test/journeys/todos/todos_injector.dart';
import 'package:axscend_tech_test/journeys/users/users_injector.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';

/// The app's one service locator. Only injectors, `BlocProvider(create:)`
/// and route builders read it; everything else gets its dependencies through
/// its constructor.
final GetIt getIt = GetIt.instance;

/// Registers everything once, before `runApp`.
///
/// The only file that knows which backend the app uses. The rest of the app
/// sees the `domain` repository contracts, so swapping the backend changes
/// the lines below and nothing else.
void configureDependencies() {
  getIt
    ..registerLazySingleton<JsonPlaceholderBackend>(JsonPlaceholderBackend.new)
    ..registerLazySingleton<UserRepository>(
      () => getIt<JsonPlaceholderBackend>().users,
    )
    ..registerLazySingleton<PostRepository>(
      () => getIt<JsonPlaceholderBackend>().posts,
    )
    ..registerLazySingleton<AlbumRepository>(
      () => getIt<JsonPlaceholderBackend>().albums,
    )
    ..registerLazySingleton<TodoRepository>(
      () => getIt<JsonPlaceholderBackend>().todos,
    );
  UsersInjector.init();
  AlbumsInjector.init();
  PostsInjector.init();
  TodosInjector.init();
}
