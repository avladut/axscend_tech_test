import 'dart:async';

import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads whatever the test hands it, and records each request.
class _TestBloc extends LoadBloc<String> {
  new(this.answer);

  Future<String> Function() answer;
  final requests = <bool>[];

  @override
  Future<String> load({required bool refresh}) {
    requests.add(refresh);
    return answer();
  }
}

void main() {
  group(LoadBloc, () {
    test('starts with nothing loaded', () {
      expect(_TestBloc(() async => 'a').state, const LoadState<String>());
    });

    blocTest<_TestBloc, LoadState<String>>(
      'loads, from the cache unless refreshing',
      build: () => _TestBloc(() async => 'data'),
      act: (bloc) => bloc.add(const LoadRequested()),
      expect: () => const [
        LoadState<String>(status: LoadStatus.loading),
        LoadState(status: LoadStatus.success, data: 'data'),
      ],
      verify: (bloc) => expect(bloc.requests, [false]),
    );

    blocTest<_TestBloc, LoadState<String>>(
      'keeps the data while a refresh runs',
      build: () => _TestBloc(() async => 'new'),
      seed: () => const LoadState(status: LoadStatus.success, data: 'old'),
      act: (bloc) => bloc.add(const LoadRequested(refresh: true)),
      expect: () => const [
        LoadState(status: LoadStatus.loading, data: 'old'),
        LoadState(status: LoadStatus.success, data: 'new'),
      ],
      verify: (bloc) => expect(bloc.requests, [true]),
    );

    blocTest<_TestBloc, LoadState<String>>(
      'keeps the failure for the View to explain',
      build: () => _TestBloc(() async => throw const OfflineFailure()),
      act: (bloc) => bloc.add(const LoadRequested()),
      expect: () => const [
        LoadState<String>(status: LoadStatus.loading),
        LoadState<String>(
          status: LoadStatus.failure,
          failure: OfflineFailure(),
        ),
      ],
    );

    test('drops a request while one is loading', () async {
      final slow = Completer<String>();
      final bloc = _TestBloc(() => slow.future)
        ..add(const LoadRequested())
        ..add(const LoadRequested(refresh: true));
      await pumpEventQueue();
      slow.complete('data');
      await pumpEventQueue();

      expect(bloc.requests, [false]);
      expect(bloc.state.data, 'data');
      await bloc.close();
    });

    test('refresh completes once fresh data has arrived', () async {
      final bloc = _TestBloc(() async => 'fresh');

      await bloc.refresh();

      expect(bloc.state.data, 'fresh');
      expect(bloc.requests, [true]);
      await bloc.close();
    });

    test('refresh completes if the bloc closes first', () async {
      final bloc = _TestBloc(() => Completer<String>().future);
      final refreshed = bloc.refresh();
      await pumpEventQueue();

      await bloc.close();
      await expectLater(refreshed, completes);
    });
  });

  group('loadBoth', () {
    test('gives both answers', () async {
      expect(await loadBoth(Future.value(1), Future.value('a')), (1, 'a'));
    });

    test('throws the failure itself, from either side', () async {
      await expectLater(
        loadBoth(Future<int>.error(const NotFoundFailure()), Future.value(1)),
        throwsA(isA<NotFoundFailure>()),
      );
      await expectLater(
        loadBoth(Future.value(1), Future<int>.error(const OfflineFailure())),
        throwsA(isA<OfflineFailure>()),
      );
    });
  });
}
