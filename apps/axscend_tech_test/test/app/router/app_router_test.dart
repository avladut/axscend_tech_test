import 'package:axscend_tech_test/app/app.dart';
import 'package:axscend_tech_test/app/router/app_router.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:axscend_tech_test/journeys/albums/screens/album_photos_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/photo_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/user_albums_screen.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:axscend_tech_test/journeys/posts/screens/post_screen.dart';
import 'package:axscend_tech_test/journeys/posts/screens/user_posts_screen.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/screens/user_todos_screen.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:axscend_tech_test/journeys/users/screens/user_profile_screen.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/albums.dart';
import '../../helpers/posts_todos.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/users.dart';

void main() {
  group('appRedirect', () {
    test('sends the root to the users', () {
      expect(appRedirect('/'), '/users');
    });

    test('leaves every other address alone', () {
      expect(appRedirect('/users'), isNull);
      expect(appRedirect('/nowhere'), isNull);
    });
  });

  group('createAppRouter', () {
    // Each screen fails to load: no spinner keeps pumpAndSettle waiting,
    // and no picture needs the network.
    const failed = LoadStatus.failure;
    final addresses = <Object>[];
    final profiles = <int>[];

    setUp(() {
      addresses.clear();
      profiles.clear();
      final users = MockUsersBloc();
      when(() => users.state).thenReturn(
        UsersState(status: UsersStatus.success, window: windowOf(const [])),
      );
      final userAlbums = MockUserAlbumsBloc();
      when(
        () => userAlbums.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final albumPhotos = MockAlbumPhotosBloc();
      when(
        () => albumPhotos.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final photo = MockPhotoBloc();
      when(
        () => photo.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final profile = MockUserProfileBloc();
      when(
        () => profile.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final userPosts = MockUserPostsBloc();
      when(
        () => userPosts.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final post = MockPostBloc();
      when(
        () => post.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      final userTodos = MockUserTodosBloc();
      when(
        () => userTodos.state,
      ).thenReturn(const LoadState(status: failed, failure: OfflineFailure()));
      getIt
        ..registerFactory<UsersBloc>(() => users)
        ..registerFactoryParam<UserProfileBloc, int, void>((userId, _) {
          profiles.add(userId);
          return profile;
        })
        ..registerFactoryParam<UserPostsBloc, int, void>((userId, _) {
          addresses.add(('posts', userId));
          return userPosts;
        })
        ..registerFactoryParam<PostBloc, PostAddress, void>((address, _) {
          addresses.add(address);
          return post;
        })
        ..registerFactoryParam<UserTodosBloc, int, void>((userId, _) {
          addresses.add(('todos', userId));
          return userTodos;
        })
        ..registerFactoryParam<UserAlbumsBloc, int, void>((userId, _) {
          addresses.add(userId);
          return userAlbums;
        })
        ..registerFactoryParam<AlbumPhotosBloc, AlbumAddress, void>((
          address,
          _,
        ) {
          addresses.add(address);
          return albumPhotos;
        })
        ..registerFactoryParam<PhotoBloc, PhotoAddress, void>((address, _) {
          addresses.add(address);
          return photo;
        });
    });
    tearDown(getIt.reset);

    Future<void> open(WidgetTester tester, String location) async {
      await tester.pumpWidget(
        App(router: createAppRouter(initialLocation: location)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opens on the users', (tester) async {
      await open(tester, '/');

      expect(find.byType(UsersScreen), findsOneWidget);
    });

    testWidgets("a link opens a user's albums, above their profile", (
      tester,
    ) async {
      await open(tester, '/users/7/albums');

      expect(find.byType(UserAlbumsScreen), findsOneWidget);
      expect(addresses, [7]);
      expect(find.byType(UsersScreen, skipOffstage: false), findsOneWidget);
      expect(
        find.byType(UserProfileScreen, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets("a link opens an album's photos", (tester) async {
      await open(tester, '/users/7/albums/3');

      expect(find.byType(AlbumPhotosScreen), findsOneWidget);
      expect(addresses, contains((userId: 7, albumId: 3)));
    });

    testWidgets('a link opens one photo', (tester) async {
      await open(tester, '/users/7/albums/3/photos/2');

      expect(find.byType(PhotoScreen), findsOneWidget);
      expect(addresses, contains((userId: 7, albumId: 3, photoId: 2)));
    });

    testWidgets('the same page with other ids gets a fresh bloc', (
      tester,
    ) async {
      final router = createAppRouter(initialLocation: '/users/1/albums');
      await tester.pumpWidget(App(router: router));
      await tester.pumpAndSettle();

      router.go('/users/2/albums');
      await tester.pumpAndSettle();
      router.go('/users/2/albums/3/photos/4');
      await tester.pumpAndSettle();
      router.go('/users/2/albums/3/photos/5');
      await tester.pumpAndSettle();

      // The album page under the photo builds its own bloc too.
      expect(
        addresses,
        containsAllInOrder(<Object>[
          1,
          2,
          (userId: 2, albumId: 3, photoId: 4),
          (userId: 2, albumId: 3, photoId: 5),
        ]),
      );
    });

    testWidgets('swiping from the left edge goes back on iOS', (tester) async {
      await open(tester, '/users/7/albums');
      expect(find.byType(UserAlbumsScreen), findsOneWidget);

      await tester.timedDragFrom(
        const Offset(5, 300),
        const Offset(500, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(find.byType(UserAlbumsScreen), findsNothing);
      expect(find.byType(UserProfileScreen), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('a new page slides in rather than appearing at once', (
      tester,
    ) async {
      final router = createAppRouter(initialLocation: '/users');
      await tester.pumpWidget(App(router: router));
      await tester.pumpAndSettle();

      router.go('/users/7/albums');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Mid-transition, both pages are on screen.
      expect(find.byType(UsersScreen), findsOneWidget);
      expect(find.byType(UserAlbumsScreen), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets("a link opens a user's profile", (tester) async {
      await open(tester, '/users/7');

      expect(find.byType(UserProfileScreen), findsOneWidget);
      expect(profiles, [7]);
    });

    testWidgets("a link opens a user's posts, and one post", (tester) async {
      await open(tester, '/users/7/posts');
      expect(find.byType(UserPostsScreen), findsOneWidget);

      await open(tester, '/users/7/posts/3');
      expect(find.byType(PostScreen), findsOneWidget);
      expect(
        addresses,
        containsAllInOrder(<Object>[('posts', 7), (userId: 7, postId: 3)]),
      );
    });

    testWidgets("a link opens a user's todos", (tester) async {
      await open(tester, '/users/7/todos');

      expect(find.byType(UserTodosScreen), findsOneWidget);
      expect(addresses, contains(('todos', 7)));
    });

    testWidgets('an id that is not a number is "page not found"', (
      tester,
    ) async {
      await open(tester, '/users/abc/albums');

      expect(find.text(l10n.notFoundTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows "page not found" for an unknown address, with a way '
        'back', (tester) async {
      await open(tester, '/nowhere');

      expect(find.text(l10n.notFoundTitle), findsOneWidget);
      await tester.tap(find.text(l10n.notFoundAction));
      await tester.pumpAndSettle();
      expect(find.byType(UsersScreen), findsOneWidget);
    });
  });
}
