import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('configureDependencies', () {
    setUp(configureDependencies);
    tearDown(getIt.reset);

    test('offers each repository contract, one shared instance each', () {
      expect(getIt<UserRepository>(), same(getIt<UserRepository>()));
      expect(getIt<PostRepository>(), same(getIt<PostRepository>()));
      expect(getIt<AlbumRepository>(), same(getIt<AlbumRepository>()));
      expect(getIt<TodoRepository>(), same(getIt<TodoRepository>()));
    });

    test('makes a fresh UsersBloc for every screen', () async {
      final first = getIt<UsersBloc>();
      final second = getIt<UsersBloc>();
      expect(first, isNot(same(second)));
      await Future.wait([first.close(), second.close()]);
    });

    test('makes each album bloc for the ids it is given', () async {
      final userAlbums = getIt<UserAlbumsBloc>(param1: 7);
      final albumPhotos = getIt<AlbumPhotosBloc>(
        param1: (userId: 7, albumId: 3),
      );
      final photo = getIt<PhotoBloc>(
        param1: (userId: 7, albumId: 3, photoId: 2),
      );

      expect(userAlbums.userId, 7);
      expect(albumPhotos.address, (userId: 7, albumId: 3));
      expect(photo.address, (userId: 7, albumId: 3, photoId: 2));
      expect(getIt<UserAlbumsBloc>(param1: 7), isNot(same(userAlbums)));
      await Future.wait([
        userAlbums.close(),
        albumPhotos.close(),
        photo.close(),
      ]);
    });

    test('makes the profile, posts and todos blocs for their ids', () async {
      final profile = getIt<UserProfileBloc>(param1: 7);
      final posts = getIt<UserPostsBloc>(param1: 7);
      final post = getIt<PostBloc>(param1: (userId: 7, postId: 3));
      final todos = getIt<UserTodosBloc>(param1: 7);

      expect(profile.userId, 7);
      expect(posts.userId, 7);
      expect(post.address, (userId: 7, postId: 3));
      expect(todos.userId, 7);
      await Future.wait([
        profile.close(),
        posts.close(),
        post.close(),
        todos.close(),
      ]);
    });
  });
}
