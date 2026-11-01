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
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/albums.dart';
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

    setUp(() {
      addresses.clear();
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
      getIt
        ..registerFactory<UsersBloc>(() => users)
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

    testWidgets("a link opens a user's albums, above the users", (
      tester,
    ) async {
      await open(tester, '/users/7/albums');

      expect(find.byType(UserAlbumsScreen), findsOneWidget);
      expect(addresses, [7]);
      expect(find.byType(UsersScreen, skipOffstage: false), findsOneWidget);
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
      expect(find.byType(UsersScreen), findsOneWidget);
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
