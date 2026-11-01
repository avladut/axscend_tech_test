import 'dart:async';

import 'package:axscend_tech_test/common/paging/paged_window.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/users.dart';

void main() {
  late MockUserRepository repository;
  // Small pages, so a few users make several pages.
  const small = PagedWindow<User>(pageSize: 2, maxPages: 2);
  final first = testUsers(2);
  final second = testUsers(2, firstId: 3);
  final third = testUsers(2, firstId: 5);

  setUpAll(registerUserFallbacks);
  setUp(() => repository = MockUserRepository());

  UsersBloc build({PagedWindow<User> window = small}) => UsersBloc(
    repository: repository,
    searchDelay: const Duration(milliseconds: 10),
    window: window,
  );

  /// Answers page [index] of a 6-user list with [users].
  void answerPage(int index, List<User> users, {int total = 6}) => when(
    () => repository.getUsersPage(
      PageRequest(index: index, size: 2),
      query: any(named: 'query'),
      refresh: any(named: 'refresh'),
    ),
  ).thenAnswer((_) async => ResultPage(items: users, total: total));

  /// The (page, query, refresh) of every call to the repository.
  List<(int, UserQuery, bool)> calls() {
    final captured = verify(
      () => repository.getUsersPage(
        captureAny(),
        query: captureAny(named: 'query'),
        refresh: captureAny(named: 'refresh'),
      ),
    ).captured;
    return [
      for (var i = 0; i < captured.length; i += 3)
        (
          (captured[i] as PageRequest).index,
          captured[i + 1] as UserQuery,
          captured[i + 2] as bool,
        ),
    ];
  }

  final loaded = UsersState(
    status: UsersStatus.success,
    window: small.withPage(0, first, total: 6),
  );

  test('starts with nothing loaded, at most 60 users in memory', () {
    final state = UsersBloc(repository: repository).state;
    expect(state.status, UsersStatus.initial);
    expect(state.window.total, isNull);
    expect(state.window.pageSize * state.window.maxPages, 60);
  });

  group('UsersLoadRequested', () {
    blocTest<UsersBloc, UsersState>(
      'loads the first page from the cache when it can',
      setUp: () => answerPage(0, first),
      build: build,
      act: (bloc) => bloc.add(const UsersLoadRequested()),
      expect: () => [
        const UsersState(status: UsersStatus.loading, window: small),
        loaded,
      ],
      verify: (_) => expect(calls(), [(0, const UserQuery(), false)]),
    );

    blocTest<UsersBloc, UsersState>(
      'a refresh asks again, keeps the list meanwhile, then starts over',
      setUp: () => answerPage(0, first),
      build: build,
      seed: () => UsersState(
        status: UsersStatus.success,
        window: loaded.window.withPage(1, second, total: 6),
      ),
      act: (bloc) => bloc.add(const UsersLoadRequested(refresh: true)),
      skip: 1,
      expect: () => [loaded],
      verify: (_) => expect(calls(), [(0, const UserQuery(), true)]),
    );

    blocTest<UsersBloc, UsersState>(
      'keeps the failure for the View to explain',
      setUp: () =>
          when(() => repository.getUsersPage(any(), query: any(named: 'query')))
              .thenThrow(const OfflineFailure(detail: 'timeout')),
      build: build,
      act: (bloc) => bloc.add(const UsersLoadRequested()),
      expect: () => [
        const UsersState(status: UsersStatus.loading, window: small),
        const UsersState(
          status: UsersStatus.failure,
          window: small,
          failure: OfflineFailure(detail: 'timeout'),
        ),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'clears the last failure when trying again',
      setUp: () => answerPage(0, first),
      build: build,
      seed: () => const UsersState(
        status: UsersStatus.failure,
        window: small,
        failure: ServerFailure(500),
      ),
      act: (bloc) => bloc.add(const UsersLoadRequested(refresh: true)),
      expect: () => [
        const UsersState(status: UsersStatus.loading, window: small),
        loaded,
      ],
    );

    test('a newer change wins over an older load still running', () async {
      final slow = Completer<ResultPage<User>>();
      when(() => repository.getUsersPage(any())).thenAnswer((_) => slow.future);
      when(
        () => repository.getUsersPage(
          any(),
          query: const UserQuery(sort: UserSort.city),
        ),
      ).thenAnswer((_) async => ResultPage(items: second, total: 2));
      final bloc = build()
        ..add(const UsersLoadRequested())
        ..add(const UsersSortChanged(UserSort.city));
      await pumpEventQueue();
      slow.complete(ResultPage(items: first, total: 6));
      await pumpEventQueue();

      expect(bloc.state.window.itemAt(0), second.first);
      expect(bloc.state.window.total, 2);
      await bloc.close();
    });
  });

  group('UsersSearchChanged', () {
    blocTest<UsersBloc, UsersState>(
      'waits for typing to pause, then searches once',
      setUp: () => answerPage(0, second, total: 2),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc
        ..add(const UsersSearchChanged('r'))
        ..add(const UsersSearchChanged('ro'))
        ..add(const UsersSearchChanged('rom')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(calls(), [(0, const UserQuery(text: 'rom'), false)]);
        expect(bloc.state.query.text, 'rom');
        expect(bloc.state.window.total, 2);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'does nothing when the text is the same',
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const UsersSearchChanged('')),
      wait: const Duration(milliseconds: 50),
      expect: () => <UsersState>[],
    );

    blocTest<UsersBloc, UsersState>(
      'a sort picked while a search waits keeps the typed text',
      setUp: () => answerPage(0, second, total: 2),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc
        ..add(const UsersSearchChanged('rom'))
        ..add(const UsersSortChanged(UserSort.city)),
      wait: const Duration(milliseconds: 50),
      verify: (_) => expect(calls(), [
        (0, const UserQuery(text: 'rom', sort: UserSort.city), false),
      ]),
    );
  });

  blocTest<UsersBloc, UsersState>(
    'UsersSortChanged starts over from the first page in that order',
    setUp: () => answerPage(0, second),
    build: build,
    seed: () => UsersState(
      status: UsersStatus.success,
      window: loaded.window.withPage(1, second, total: 6),
    ),
    act: (bloc) => bloc.add(const UsersSortChanged(UserSort.company)),
    expect: () => [
      UsersState(
        status: UsersStatus.success,
        query: const UserQuery(sort: UserSort.company),
        window: loaded.window.withPage(1, second, total: 6),
      ),
      UsersState(
        status: UsersStatus.loading,
        query: const UserQuery(sort: UserSort.company),
        window: loaded.window.withPage(1, second, total: 6),
      ),
      UsersState(
        status: UsersStatus.success,
        query: const UserQuery(sort: UserSort.company),
        window: small.withPage(0, second, total: 6),
      ),
    ],
  );

  group('UsersPageRequested', () {
    blocTest<UsersBloc, UsersState>(
      'loads the page into the window',
      setUp: () => answerPage(1, second),
      build: build,
      seed: () => loaded,
      act: (bloc) => bloc.add(const UsersPageRequested(1)),
      expect: () => [
        loaded.copyWith(window: loaded.window.withLoading(1)),
        loaded.copyWith(window: loaded.window.withPage(1, second, total: 6)),
      ],
      verify: (_) => expect(calls(), [(1, const UserQuery(), false)]),
    );

    blocTest<UsersBloc, UsersState>(
      'never keeps more pages than the limit',
      setUp: () {
        answerPage(1, second);
        answerPage(2, third);
      },
      build: build,
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(const UsersPageRequested(1));
        await pumpEventQueue();
        bloc.add(const UsersPageRequested(2));
      },
      verify: (bloc) {
        final window = bloc.state.window;
        expect(window.pages.keys, unorderedEquals([1, 2]));
        expect(window.itemsInMemory, 4);
        expect(window.itemAt(0), isNull);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'asks once for a page that is loaded, loading or not in the list',
      build: build,
      seed: () => loaded.copyWith(window: loaded.window.withLoading(1)),
      act: (bloc) => bloc
        ..add(const UsersPageRequested(0))
        ..add(const UsersPageRequested(1))
        ..add(const UsersPageRequested(3)),
      expect: () => <UsersState>[],
      verify: (_) => verifyNever(
        () => repository.getUsersPage(any(), query: any(named: 'query')),
      ),
    );

    blocTest<UsersBloc, UsersState>(
      'asks for nothing before the first page arrives',
      build: build,
      act: (bloc) => bloc.add(const UsersPageRequested(0)),
      expect: () => <UsersState>[],
    );

    blocTest<UsersBloc, UsersState>(
      'marks a page that failed, and tries again when asked',
      setUp: () => when(
        () => repository.getUsersPage(
          const PageRequest(index: 1, size: 2),
          query: any(named: 'query'),
        ),
      ).thenThrow(const OfflineFailure()),
      build: build,
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(const UsersPageRequested(1));
        await pumpEventQueue();
        answerPage(1, second);
        bloc.add(const UsersPageRequested(1));
      },
      expect: () => [
        loaded.copyWith(window: loaded.window.withLoading(1)),
        loaded.copyWith(window: loaded.window.withFailed(1)),
        loaded.copyWith(window: loaded.window.withLoading(1)),
        loaded.copyWith(window: loaded.window.withPage(1, second, total: 6)),
      ],
    );

    test('drops a page that arrives after the list changed', () async {
      final slow = Completer<ResultPage<User>>();
      when(
        () => repository.getUsersPage(
          const PageRequest(index: 1, size: 2),
          query: any(named: 'query'),
        ),
      ).thenAnswer((_) => slow.future);
      answerPage(0, third, total: 2);
      final bloc = build()
        ..emit(loaded)
        ..add(const UsersPageRequested(1));
      await pumpEventQueue();
      bloc.add(const UsersSortChanged(UserSort.city));
      await pumpEventQueue();
      slow.complete(ResultPage(items: second, total: 6));
      await pumpEventQueue();

      expect(bloc.state.window, small.withPage(0, third, total: 2));
      await bloc.close();
    });

    test('keeps at most 60 users in memory, however far you scroll', () async {
      when(() => repository.getUsersPage(any(), query: any(named: 'query')))
          .thenAnswer((invocation) async {
            final page = invocation.positionalArguments.first as PageRequest;
            return ResultPage(
              items: testUsers(20, firstId: page.offset + 1),
              total: 1000,
            );
          });
      final bloc = UsersBloc(repository: repository)
        ..add(const UsersLoadRequested());
      await pumpEventQueue();
      for (var page = 1; page < 50; page++) {
        bloc.add(UsersPageRequested(page));
        await pumpEventQueue();
        expect(bloc.state.window.itemsInMemory, lessThanOrEqualTo(60));
      }

      final window = bloc.state.window;
      expect(window.pages.keys, unorderedEquals([47, 48, 49]));
      expect(window.itemAt(999)!.id, 1000);
      await bloc.close();
    });
  });
}
