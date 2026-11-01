import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/users.dart';

/// A backend with [total] users, answering pages straight away.
class _ManyUsers implements UserRepository {
  new(this.total);

  final int total;
  final asked = <int>[];

  @override
  Future<ResultPage<User>> getUsersPage(
    PageRequest page, {
    UserQuery query = const UserQuery(),
    bool refresh = false,
  }) async {
    asked.add(page.index);
    final last = (page.offset + page.size).clamp(0, total);
    return ResultPage(
      items: testUsers(last - page.offset, firstId: page.offset + 1),
      total: total,
    );
  }

  @override
  Future<List<User>> getUsers({bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<User> getUser(int id, {bool refresh = false}) =>
      throw UnimplementedError();
}

void main() {
  late MockUsersBloc bloc;
  final users = [
    testUser(name: 'Ervin Howell', username: 'Antonette'),
    testUser(id: 2, name: 'Leanne Graham', username: 'Bret', company: 'Acme'),
  ];
  final loaded = UsersState(
    status: UsersStatus.success,
    window: windowOf(users),
  );

  setUp(() => bloc = MockUsersBloc());

  Future<void> pumpView(
    WidgetTester tester,
    UsersState state, {
    Size? size,
  }) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<UsersBloc>.value(value: bloc, child: const UsersView()),
      size: size,
    );
  }

  group(UsersScreen, () {
    setUp(() => getIt.registerFactory<UsersBloc>(() => bloc));
    tearDown(getIt.reset);

    testWidgets('gets its bloc from the injector and starts loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const UsersState());
      await tester.pumpApp(const UsersScreen());

      expect(find.byType(UsersView), findsOneWidget);
      verify(() => bloc.add(const UsersLoadRequested())).called(1);
    });
  });

  group(UsersView, () {
    testWidgets('shows a spinner until the first page arrives', (tester) async {
      await pumpView(tester, const UsersState(status: UsersStatus.loading));

      expect(find.text(l10n.usersLoading), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('lists the users in the order given, with the total', (
      tester,
    ) async {
      await pumpView(
        tester,
        loaded.copyWith(window: windowOf(users, total: 42)),
      );

      expect(find.text(l10n.usersAllHeader), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('@Bret · Acme'), findsOneWidget);
      final ervin = tester.getTopLeft(find.text('Ervin Howell'));
      final leanne = tester.getTopLeft(find.text('Leanne Graham'));
      expect(ervin.dy, lessThan(leanne.dy));
    });

    testWidgets('keeps the list while a new list loads', (tester) async {
      await pumpView(tester, loaded.copyWith(status: UsersStatus.loading));

      expect(find.text('Leanne Graham'), findsOneWidget);
      expect(find.text(l10n.usersLoading), findsNothing);
    });

    testWidgets('builds only the rows on screen', (tester) async {
      await pumpView(
        tester,
        loaded.copyWith(window: windowOf(testUsers(20), total: 1000)),
        size: TestWindows.phone,
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(
        find.byType(AppListTile).evaluate().length,
        lessThan(20),
        reason: 'rows below the screen are not built',
      );
    });

    testWidgets('a row whose page is not in memory waits for it, and asks', (
      tester,
    ) async {
      await pumpView(
        tester,
        loaded.copyWith(window: windowOf(users, total: 4, pageSize: 2)),
      );

      expect(find.byType(AppListTilePlaceholder), findsNWidgets(2));
      expect(find.bySemanticsLabel(l10n.usersRowLoading), findsNWidgets(2));
      verify(() => bloc.add(const UsersPageRequested(1))).called(2);
    });

    testWidgets('a row whose page failed offers to try again', (tester) async {
      await pumpView(
        tester,
        loaded.copyWith(
          window: windowOf(users, total: 3, pageSize: 2).withFailed(1),
        ),
      );

      expect(find.byType(AppListTilePlaceholder), findsNothing);
      await tester.tap(find.text(l10n.usersRowFailed));
      verify(() => bloc.add(const UsersPageRequested(1))).called(1);
    });

    testWidgets('fits phones and tablets', (tester) async {
      for (final size in [TestWindows.phone, TestWindows.tablet]) {
        await pumpView(tester, loaded, size: size);
        expect(tester.takeException(), isNull, reason: '$size');
        expect(find.text('Leanne Graham'), findsOneWidget, reason: '$size');
      }
    });

    testWidgets('explains a failure and tries again', (tester) async {
      await pumpView(
        tester,
        const UsersState(
          status: UsersStatus.failure,
          failure: OfflineFailure(),
        ),
      );

      expect(find.text(l10n.failureOfflineTitle), findsOneWidget);
      await tester.tap(find.text(l10n.tryAgain));
      verify(() => bloc.add(const UsersLoadRequested(refresh: true))).called(1);
    });

    testWidgets('says so when there are no users at all', (tester) async {
      await pumpView(tester, loaded.copyWith(window: windowOf(const [])));

      expect(find.text(l10n.usersEmptyTitle), findsOneWidget);
    });

    testWidgets('shows the results of a search', (tester) async {
      await pumpView(
        tester,
        loaded.copyWith(query: const UserQuery(text: 'leanne')),
      );

      expect(find.text(l10n.usersResultsHeader), findsOneWidget);
    });

    testWidgets('says so when a search finds no one', (tester) async {
      await pumpView(
        tester,
        loaded.copyWith(
          query: const UserQuery(text: ' zzz '),
          window: windowOf(const []),
        ),
      );

      expect(find.text(l10n.usersNoMatchTitle('zzz')), findsOneWidget);
      expect(find.text(l10n.usersNoMatchMessage), findsOneWidget);
    });

    testWidgets('sends what is typed in the search field', (tester) async {
      await pumpView(tester, loaded);

      await tester.enterText(find.byType(TextField), 'erv');
      verify(() => bloc.add(const UsersSearchChanged('erv'))).called(1);
    });

    testWidgets('offers every sort and sends the one picked', (tester) async {
      await pumpView(tester, loaded);

      await tester.tap(find.byTooltip(l10n.usersSortTooltip));
      await tester.pumpAndSettle();
      for (final label in [
        l10n.usersSortNameAscending,
        l10n.usersSortNameDescending,
        l10n.usersSortCompany,
        l10n.usersSortCity,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text(l10n.usersSortCity));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const UsersSortChanged(UserSort.city))).called(1);
    });

    testWidgets('pull to refresh asks again and waits for the answer', (
      tester,
    ) async {
      final states = StreamController<UsersState>.broadcast();
      addTearDown(states.close);
      whenListen(bloc, states.stream, initialState: loaded);
      await pumpView(tester, loaded);

      await tester.fling(find.text('Ervin Howell'), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      verify(() => bloc.add(const UsersLoadRequested(refresh: true))).called(1);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);

      states.add(loaded);
      await tester.pumpAndSettle();
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('pull to refresh stops quietly if the bloc closes first', (
      tester,
    ) async {
      final states = StreamController<UsersState>.broadcast();
      whenListen(bloc, states.stream, initialState: loaded);
      await pumpView(tester, loaded);

      await tester.fling(find.text('Ervin Howell'), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);

      await states.close();
      await tester.pumpAndSettle();
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });
  });

  group('UsersView with a real bloc', () {
    testWidgets('scrolls through 1,000 users with at most 60 in memory', (
      tester,
    ) async {
      final backend = _ManyUsers(1000);
      final real = UsersBloc(repository: backend)
        ..add(const UsersLoadRequested());
      addTearDown(real.close);
      await tester.pumpApp(
        BlocProvider.value(value: real, child: const UsersView()),
        size: TestWindows.phone,
      );
      await tester.pumpAndSettle();
      expect(find.text('Person 1'), findsOneWidget);

      for (var drag = 0; drag < 30; drag++) {
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(real.state.window.itemsInMemory, lessThanOrEqualTo(60));
        expect(find.byType(AppListTilePlaceholder), findsNothing);
      }
      expect(find.text('Person 1'), findsNothing);
      final pagesDown = backend.asked.length;
      expect(pagesDown, lessThan(20), reason: 'each page asked for once');

      // Back to the top: the first page was dropped, so it comes back.
      for (var drag = 0; drag < 30; drag++) {
        await tester.drag(find.byType(ListView), const Offset(0, 600));
        await tester.pumpAndSettle();
        expect(real.state.window.itemsInMemory, lessThanOrEqualTo(60));
      }
      await tester.dragUntilVisible(
        find.text('Person 1'),
        find.byType(ListView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      expect(find.text('Person 1'), findsOneWidget);
      expect(backend.asked.skip(pagesDown), contains(0));
      expect(
        backend.asked,
        hasLength(lessThan(30)),
        reason: 'no page is asked for over and over',
      );
    });
  });
}
