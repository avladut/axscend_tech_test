import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';

/// What the posts journey needs. Each bloc is a factory, so every screen
/// gets a fresh one for the ids in its address.
abstract final class PostsInjector {
  static void init() {
    getIt
      ..registerFactoryParam<UserPostsBloc, int, void>(
        (userId, _) =>
            UserPostsBloc(userId: userId, users: getIt(), posts: getIt()),
      )
      ..registerFactoryParam<PostBloc, PostAddress, void>(
        (address, _) => PostBloc(address: address, posts: getIt()),
      );
  }
}
