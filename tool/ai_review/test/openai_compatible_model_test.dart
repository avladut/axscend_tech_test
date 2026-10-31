import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ai_review/ai_review.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(OpenAiCompatibleModel, () {
    late List<http.BaseRequest> requests;
    late List<Map<String, Object?>> bodies;

    OpenAiCompatibleModel modelWith(
      List<FutureOr<http.StreamedResponse> Function()> responses, {
      Duration timeout = const Duration(seconds: 5),
    }) {
      requests = [];
      bodies = [];
      var index = 0;
      final client = MockClient.streaming((request, body) async {
        requests.add(request);
        bodies.add(
          jsonDecode(await body.bytesToString()) as Map<String, Object?>,
        );
        return await responses[index++]();
      });
      return OpenAiCompatibleModel(
        baseUrl: Uri.parse('https://models.example/v1'),
        apiKey: 'test-key',
        name: 'qwen38-flash',
        client: client,
        timeout: timeout,
        retryDelay: Duration.zero,
      );
    }

    http.StreamedResponse status(int code) =>
        http.StreamedResponse(Stream.value(utf8.encode('{}')), code);

    test('streams the answer and the token counts', () async {
      final model = modelWith([
        () => sseResponse(
          ['{"summary": ', '"ok", "findings": []}'],
          usage: {'prompt_tokens': 1200, 'completion_tokens': 34},
        ),
      ]);

      final reply = await model.complete(
        system: 'sys',
        user: 'usr',
        jsonSchema: ReviewParser.schema,
      );

      expect(reply.text, '{"summary": "ok", "findings": []}');
      expect(reply.promptTokens, 1200);
      expect(reply.completionTokens, 34);

      final request = requests.single;
      expect(
        request.url.toString(),
        'https://models.example/v1/chat/completions',
      );
      expect(request.headers['Authorization'], 'Bearer test-key');
      final body = bodies.single;
      expect(body['model'], 'qwen38-flash');
      expect(body['stream'], isTrue);
      expect(body['messages'], [
        {'role': 'system', 'content': 'sys'},
        {'role': 'user', 'content': 'usr'},
      ]);
      expect(body['response_format'], isA<Map<String, Object?>>());
    });

    test('retries once after a server error', () async {
      final model = modelWith([
        () => status(503),
        () => sseResponse(['{}']),
      ]);

      final reply = await model.complete(system: 's', user: 'u');

      expect(reply.text, '{}');
      expect(requests, hasLength(2));
    });

    test('gives up after the retry', () async {
      final model = modelWith([() => status(502), () => status(502)]);

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(
          isA<ReviewModelException>().having(
            (e) => e.message,
            'message',
            contains('HTTP 502'),
          ),
        ),
      );
      expect(requests, hasLength(2));
    });

    test('does not retry a rejected key', () async {
      final model = modelWith([() => status(401)]);

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(isA<ReviewModelException>()),
      );
      expect(requests, hasLength(1));
    });

    test('asks again without the schema when the server rejects it', () async {
      final model = modelWith([
        () => status(400),
        () => sseResponse(['{}']),
      ]);

      await model.complete(
        system: 's',
        user: 'u',
        jsonSchema: ReviewParser.schema,
      );

      expect(bodies.first.containsKey('response_format'), isTrue);
      expect(bodies.last.containsKey('response_format'), isFalse);
    });

    test('never puts the server address in its error message', () async {
      final model = modelWith([
        () => throw http.ClientException(
          'Connection refused',
          Uri.parse('https://secret-host.example/v1'),
        ),
        () => throw const SocketException('secret-host.example: no route'),
      ]);

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(
          isA<ReviewModelException>().having(
            (e) => e.message,
            'message',
            allOf(contains('could not reach'), isNot(contains('secret-host'))),
          ),
        ),
      );
    });

    test('fails on an error reported inside the stream', () async {
      final model = modelWith([
        () => http.StreamedResponse(
          Stream.value(
            utf8.encode('data: {"error": {"message": "context full"}}\n\n'),
          ),
          200,
        ),
      ]);

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(isA<ReviewModelException>()),
      );
    });

    test('treats an empty answer as a failure', () async {
      final model = modelWith([() => sseResponse([]), () => sseResponse([])]);

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(
          isA<ReviewModelException>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          ),
        ),
      );
    });

    test('times out when the answer never finishes', () async {
      http.StreamedResponse never() =>
          http.StreamedResponse(StreamController<List<int>>().stream, 200);
      final model = modelWith([
        never,
        never,
      ], timeout: const Duration(milliseconds: 50));

      await expectLater(
        model.complete(system: 's', user: 'u'),
        throwsA(
          isA<ReviewModelException>().having(
            (e) => e.message,
            'message',
            contains('no complete answer'),
          ),
        ),
      );
    });
  });
}
