import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_photos.dart';
import 'package:axscend_tech_test/journeys/albums/models/user_albums.dart';
import 'package:axscend_tech_test/journeys/albums/screens/album_photos_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/photo_screen.dart';
import 'package:axscend_tech_test/journeys/albums/screens/user_albums_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/albums.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/users.dart';

void main() {
  late MockGoRouter router;
  final user = testUser(id: 7, name: 'Leanne Graham');
  final album = testAlbum(id: 3, userId: 7);
  final photos = [
    for (var id = 1; id <= 6; id++) testPhoto(id: id, albumId: 3),
  ];

  setUp(() => router = MockGoRouter());
  tearDown(getIt.reset);

  group(UserAlbumsView, () {
    late MockUserAlbumsBloc bloc;
    setUp(() => bloc = MockUserAlbumsBloc());

    Future<void> pumpView(
      WidgetTester tester,
      LoadState<UserAlbums> state,
    ) async {
      when(() => bloc.state).thenReturn(state);
      await tester.pumpApp(
        BlocProvider<UserAlbumsBloc>.value(
          value: bloc,
          child: const UserAlbumsView(),
        ),
        router: router,
      );
    }

    testWidgets('the screen gets its bloc for the user and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<UserAlbumsBloc, int, void>((userId, _) {
        expect(userId, 7);
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(const UserAlbumsScreen(userId: 7));

      verify(() => bloc.add(const LoadRequested())).called(1);
      expect(find.text(l10n.albumsLoading), findsOneWidget);
    });

    testWidgets('lists the albums under the user, and opens one', (
      tester,
    ) async {
      await pumpView(
        tester,
        loadedWith(UserAlbums(user: user, albums: [album])),
      );

      expect(find.text(l10n.albumsTitle), findsOneWidget);
      expect(find.text('Leanne Graham'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('Holidays'));
      verify(() => router.go('/users/7/albums/3')).called(1);
    });

    testWidgets('says so when the user has no albums', (tester) async {
      await pumpView(
        tester,
        loadedWith(UserAlbums(user: user, albums: const [])),
      );

      expect(find.text(l10n.albumsEmptyTitle), findsOneWidget);
    });

    testWidgets('pull to refresh asks for fresh albums', (tester) async {
      when(() => bloc.refresh()).thenAnswer((_) async {});
      await pumpView(
        tester,
        loadedWith(UserAlbums(user: user, albums: [album])),
      );

      await tester.fling(find.text('Holidays'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      verify(() => bloc.refresh()).called(1);
    });

    testWidgets('explains a failure and tries again', (tester) async {
      await pumpView(
        tester,
        const LoadState(
          status: LoadStatus.failure,
          failure: ServerFailure(500),
        ),
      );

      await tester.tap(find.text(l10n.tryAgain));
      verify(() => bloc.add(const LoadRequested(refresh: true))).called(1);
    });
  });

  group(AlbumPhotosView, () {
    late MockAlbumPhotosBloc bloc;
    setUp(() => bloc = MockAlbumPhotosBloc());

    Future<void> pumpView(
      WidgetTester tester,
      LoadState<AlbumPhotos> state, {
      Size? size,
    }) async {
      when(() => bloc.state).thenReturn(state);
      await tester.pumpApp(
        BlocProvider<AlbumPhotosBloc>.value(
          value: bloc,
          child: const AlbumPhotosView(),
        ),
        router: router,
        size: size,
      );
    }

    int columns(WidgetTester tester) =>
        (tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;

    testWidgets('the screen gets its bloc for the album and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<AlbumPhotosBloc, AlbumAddress, void>((
        address,
        _,
      ) {
        expect(address, (userId: 7, albumId: 3));
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(
        const AlbumPhotosScreen(address: (userId: 7, albumId: 3)),
      );

      verify(() => bloc.add(const LoadRequested())).called(1);
    });

    testWidgets('shows the thumbnails, and opens one', (tester) async {
      await pumpView(
        tester,
        loadedWith(AlbumPhotos(album: album, photos: photos)),
      );

      expect(find.text('Holidays'), findsOneWidget);
      final first = tester.widget<AppNetworkImage>(
        find.byType(AppNetworkImage).first,
      );
      expect(first.url, photos.first.thumbnailUrl);
      await tester.tap(find.byType(AppNetworkImage).at(1));
      verify(() => router.go('/users/7/albums/3/photos/2')).called(1);
    });

    testWidgets('adds columns as the screen widens', (tester) async {
      final loaded = loadedWith(AlbumPhotos(album: album, photos: photos));
      await pumpView(tester, loaded, size: TestWindows.phone);
      expect(columns(tester), 2);

      await pumpView(tester, loaded, size: TestWindows.tablet);
      expect(columns(tester), 7);
    });

    testWidgets('builds only the thumbnails on screen', (tester) async {
      final many = [
        for (var id = 1; id <= 50; id++) testPhoto(id: id, albumId: 3),
      ];
      await pumpView(
        tester,
        loadedWith(AlbumPhotos(album: album, photos: many)),
        size: TestWindows.phone,
      );

      expect(find.byType(AppNetworkImage).evaluate().length, lessThan(50));
    });

    testWidgets('says so when the album is empty', (tester) async {
      await pumpView(
        tester,
        loadedWith(AlbumPhotos(album: album, photos: const [])),
      );

      expect(find.text(l10n.photosEmptyTitle), findsOneWidget);
    });

    testWidgets('explains "not found" without offering a retry', (
      tester,
    ) async {
      await pumpView(
        tester,
        const LoadState(status: LoadStatus.failure, failure: NotFoundFailure()),
      );

      expect(find.text(l10n.failureNotFoundTitle), findsOneWidget);
      expect(find.text(l10n.tryAgain), findsNothing);
    });
  });

  group(PhotoView, () {
    late MockPhotoBloc bloc;
    setUp(() => bloc = MockPhotoBloc());

    testWidgets('the screen gets its bloc for the photo and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<PhotoBloc, PhotoAddress, void>((address, _) {
        expect(address, (userId: 7, albumId: 3, photoId: 2));
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(
        const PhotoScreen(address: (userId: 7, albumId: 3, photoId: 2)),
      );

      verify(() => bloc.add(const LoadRequested())).called(1);
      expect(find.text(l10n.photoLoading), findsOneWidget);
    });

    testWidgets('shows the full photo and its title', (tester) async {
      final photo = testPhoto(id: 2, albumId: 3);
      when(() => bloc.state).thenReturn(loadedWith(photo));
      await tester.pumpApp(
        BlocProvider<PhotoBloc>.value(value: bloc, child: const PhotoView()),
      );

      expect(find.text(l10n.photoTitle), findsOneWidget);
      expect(find.text('A beach'), findsOneWidget);
      final image = tester.widget<AppNetworkImage>(
        find.byType(AppNetworkImage),
      );
      expect(image.url, photo.url);
      expect(image.semanticLabel, 'A beach');
      expect(image.fit, BoxFit.contain, reason: 'never crops the photo');
    });
  });
}
