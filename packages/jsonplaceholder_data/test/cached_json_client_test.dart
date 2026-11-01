import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

/// A store that records what it's asked to keep, like a persistent one would.
class _RecordingStore implements ResponseStore {
  final saved = <String, Object>{};

  @override
  Future<Object?> read(String key) async => saved[key];

  @override
  Future<void> write(String key, Object json) async => saved[key] = json;
}

void main() {
  group(CachedJsonClient, () {
    late FakeJsonClient backend;
    late CachedJsonClient client;

    setUp(() {
      backend = FakeJsonClient({
        '/users': ['first answer'],
        '/todos': ['todos'],
      });
      client = CachedJsonClient(backend);
    });

    test('answers a repeated request from memory', () async {
      expect(await client.get<Object?>('/users'), ['first answer']);
      expect(await client.get<Object?>('/users'), ['first answer']);

      expect(backend.calls, [(path: '/users', refresh: false)]);
    });

    test('does not save a null answer, so it asks again', () async {
      backend.answers['/nothing'] = null;

      expect(await client.get<Object?>('/nothing'), isNull);
      expect(await client.get<Object?>('/nothing'), isNull);

      expect(backend.calls.map((call) => call.path), ['/nothing', '/nothing']);
    });

    test('keeps each path separately', () async {
      await client.get<Object?>('/users');
      await client.get<Object?>('/todos');

      expect(backend.calls.map((call) => call.path), ['/users', '/todos']);
    });

    test('refresh asks the backend again and keeps the new answer', () async {
      await client.get<Object?>('/users');
      backend.answers['/users'] = ['second answer'];

      expect(await client.get<Object?>('/users', refresh: true), [
        'second answer',
      ]);
      expect(await client.get<Object?>('/users'), ['second answer']);
      expect(backend.calls, [
        (path: '/users', refresh: false),
        (path: '/users', refresh: true),
      ]);
    });

    group('when the backend fails', () {
      setUp(() async {
        await client.get<Object?>('/users');
      });

      test('uses the last good answer when offline', () async {
        backend.failure = const OfflineFailure();

        expect(await client.get<Object?>('/users', refresh: true), [
          'first answer',
        ]);
      });

      test('uses the last good answer on a server error', () async {
        backend.failure = const ServerFailure(503);

        expect(await client.get<Object?>('/users', refresh: true), [
          'first answer',
        ]);
      });

      test('still fails when there is no earlier answer', () async {
        backend.failure = const OfflineFailure();

        await expectLater(
          client.get<Object?>('/todos'),
          throwsA(isA<OfflineFailure>()),
        );
      });

      test('does not hide "not found" behind old data', () async {
        backend.failure = const NotFoundFailure();

        await expectLater(
          client.get<Object?>('/users', refresh: true),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      test('does not hide bad data behind old data', () async {
        backend.failure = const UnexpectedDataFailure();

        await expectLater(
          client.get<Object?>('/users', refresh: true),
          throwsA(isA<UnexpectedDataFailure>()),
        );
      });
    });

    group('getPage', () {
      setUp(() => backend.total = 2);

      test('saves each query separately, whatever its order', () async {
        await client.getPage<Object?>(
          '/users',
          query: {'_page': '1', '_limit': '20'},
        );
        final again = await client.getPage<Object?>(
          '/users',
          query: {'_limit': '20', '_page': '1'},
        );
        await client.getPage<Object?>(
          '/users',
          query: {'_page': '2', '_limit': '20'},
        );

        expect(again.json, ['first answer']);
        expect(again.total, 2);
        expect(backend.queries, hasLength(2));
      });

      test('keeps pages apart from a plain get of the path', () async {
        await client.getPage<Object?>('/users');
        await client.get<Object?>('/users');

        expect(backend.calls, hasLength(2));
      });

      test('uses the last good page, with its total, when offline', () async {
        await client.getPage<Object?>('/users', query: {'_page': '1'});
        backend
          ..total = 99
          ..failure = const OfflineFailure();

        final page = await client.getPage<Object?>(
          '/users',
          query: {'_page': '1'},
          refresh: true,
        );
        expect(page.json, ['first answer']);
        expect(page.total, 2);
      });
    });

    group('an answer that does not parse', () {
      int? count(Object? json) => json is List
          ? json.length
          : throw const UnexpectedDataFailure(detail: 'not a list');

      setUp(() async {
        expect(await client.get('/users', parse: count), 1);
        backend.answers['/users'] = {'not': 'a list'};
      });

      test('fails, and is not saved over the good one', () async {
        await expectLater(
          client.get('/users', parse: count, refresh: true),
          throwsA(isA<UnexpectedDataFailure>()),
        );

        expect(await client.get('/users', parse: count), 1);
      });

      test('in a page fails too, and is not saved', () async {
        backend
          ..total = 1
          ..answers['/todos'] = {'not': 'a list'};

        await expectLater(
          client.getPage('/todos', parse: count),
          throwsA(isA<UnexpectedDataFailure>()),
        );
        backend.answers['/todos'] = ['todos'];
        expect((await client.getPage('/todos', parse: count)).json, 1);
      });
    });

    test('never saves a page without its total', () async {
      backend.total = null;

      await expectLater(
        client.getPage<Object?>('/users'),
        throwsA(isA<UnexpectedDataFailure>()),
      );
      backend.total = 1;
      expect((await client.getPage<Object?>('/users')).total, 1);
    });

    test(
      'works with any ResponseStore, so a persistent one can plug in',
      () async {
        final store = _RecordingStore()..saved['/todos'] = ['from disk'];
        final withStore = CachedJsonClient(backend, store: store);

        expect(await withStore.get<Object?>('/todos'), ['from disk']);
        await withStore.get<Object?>('/users');

        expect(backend.calls.map((call) => call.path), ['/users']);
        expect(store.saved['/users'], ['first answer']);
      },
    );
  });
}
