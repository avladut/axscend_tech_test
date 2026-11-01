import 'dart:async';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';
import 'package:test/test.dart';

/// Stands in for transport errors that http doesn't wrap, such as a failed
/// TLS handshake.
class _TransportException implements Exception {
  @override
  String toString() => 'handshake failed';
}

void main() {
  group(HttpJsonClient, () {
    late List<http.Request> requests;

    HttpJsonClient clientWith(
      Future<http.Response> Function(http.Request request) handler, {
      Uri? baseUrl,
      Duration timeout = const Duration(seconds: 1),
    }) {
      requests = [];
      return HttpJsonClient(
        baseUrl: baseUrl,
        timeout: timeout,
        client: MockClient((request) {
          requests.add(request);
          return handler(request);
        }),
      );
    }

    Matcher failsWith<T extends DataFailure>([Object? detail = isNotNull]) =>
        throwsA(isA<T>().having((f) => f.detail, 'detail', detail));

    test('GETs the path from JSONPlaceholder and decodes the JSON', () async {
      final client = clientWith((_) async => http.Response('[{"id": 1}]', 200));

      expect(await client.get('/users/1/posts'), [
        {'id': 1},
      ]);
      final request = requests.single;
      expect(request.method, 'GET');
      expect(
        request.url,
        Uri.parse('https://jsonplaceholder.typicode.com/users/1/posts'),
      );
      expect(request.headers['Accept'], 'application/json');
    });

    test('keeps the path of a custom base URL', () async {
      final client = clientWith(
        (_) async => http.Response('{}', 200),
        baseUrl: Uri.parse('https://api.example.test/v1/'),
      );

      await client.get('/users');

      expect(
        requests.single.url.toString(),
        'https://api.example.test/v1/users',
      );
    });

    test('asks the backend every time, refresh or not', () async {
      final client = clientWith((_) async => http.Response('[]', 200));

      await client.get('/todos');
      await client.get('/todos', refresh: true);

      expect(requests, hasLength(2));
    });

    test('turns a 404 into NotFoundFailure', () async {
      final client = clientWith((_) async => http.Response('{}', 404));

      await expectLater(
        client.get('/users/99'),
        failsWith<NotFoundFailure>('GET /users/99'),
      );
    });

    test('turns other error statuses into ServerFailure', () async {
      for (final status in [500, 503, 401]) {
        final client = clientWith((_) async => http.Response('', status));

        await expectLater(
          client.get('/users'),
          throwsA(
            isA<ServerFailure>().having((f) => f.statusCode, 'status', status),
          ),
        );
      }
    });

    test('turns no connection into OfflineFailure', () async {
      final client = clientWith(
        (_) => throw http.ClientException('Connection refused'),
      );

      await expectLater(
        client.get('/users'),
        failsWith<OfflineFailure>(contains('Connection refused')),
      );
    });

    test(
      'turns a transport error http does not wrap into OfflineFailure',
      () async {
        final client = clientWith((_) => throw _TransportException());

        await expectLater(
          client.get('/users'),
          failsWith<OfflineFailure>(
            allOf(
              contains('_TransportException'),
              contains('handshake failed'),
            ),
          ),
        );
      },
    );

    test('turns a timeout into OfflineFailure', () async {
      final client = clientWith(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 20),
      );

      await expectLater(
        client.get('/users'),
        failsWith<OfflineFailure>(contains('timed out')),
      );
    });

    test('turns a body that is not JSON into UnexpectedDataFailure', () async {
      final client = clientWith(
        (_) async => http.Response('<html>maintenance</html>', 200),
      );

      await expectLater(
        client.get('/users'),
        failsWith<UnexpectedDataFailure>(contains('not JSON')),
      );
    });
  });
}
