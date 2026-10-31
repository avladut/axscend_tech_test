import 'dart:async';
import 'dart:convert';

import 'package:ai_review/src/model/review_model.dart';
import 'package:http/http.dart' as http;

/// Talks to any OpenAI-compatible `/chat/completions` endpoint (here:
/// llama.cpp behind Alex's key-checking proxy).
///
/// The answer is streamed: the server's tunnel drops requests that send
/// nothing for about 100 seconds, and a review can take longer than that.
class OpenAiCompatibleModel implements ReviewModel {
  new({
    required Uri baseUrl,
    required this._apiKey,
    required this.name,
    http.Client? client,
    this.timeout = const Duration(minutes: 4),
    this.retryDelay = const Duration(seconds: 5),
    this.temperature = 0.2,
    this.maxTokens = 4096,
  }) : _endpoint = _chatEndpoint(baseUrl),
       _client = client ?? http.Client();

  @override
  final String name;
  final Duration timeout;
  final Duration retryDelay;
  final double temperature;
  final int maxTokens;

  final Uri _endpoint;
  final String _apiKey;
  final http.Client _client;

  /// One retry for errors that may be temporary (network, 5xx, 429, timeout).
  static const _maxAttempts = 2;

  /// `https://host/v1` → `https://host/v1/chat/completions`.
  static Uri _chatEndpoint(Uri base) {
    final path = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(path: '${path}chat/completions');
  }

  @override
  Future<ModelReply> complete({
    required String system,
    required String user,
    Map<String, Object?>? jsonSchema,
  }) async {
    var schema = jsonSchema;
    var attempt = 1;
    while (true) {
      try {
        return await _send(system, user, schema).timeout(timeout);
      } on _SchemaRejected {
        // The server doesn't support constrained output: ask without it.
        // The prompt still describes the format, and the parser is lenient.
        schema = null;
      } on _Temporary catch (error) {
        if (attempt >= _maxAttempts) throw ReviewModelException(error.message);
        attempt++;
        await Future<void>.delayed(retryDelay);
      } on TimeoutException {
        if (attempt >= _maxAttempts) {
          throw ReviewModelException(
            'no complete answer within ${timeout.inSeconds} s',
          );
        }
        attempt++;
        await Future<void>.delayed(retryDelay);
      }
    }
  }

  Future<ModelReply> _send(
    String system,
    String user,
    Map<String, Object?>? schema,
  ) async {
    final request = http.Request('POST', _endpoint)
      ..headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      })
      ..body = jsonEncode({
        'model': name,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
        'stream_options': {'include_usage': true},
        if (schema != null)
          'response_format': {
            'type': 'json_schema',
            'json_schema': {'name': 'review', 'strict': true, 'schema': schema},
          },
      });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on Exception {
      // Deliberately generic: the exception text would include the server's
      // address, and this message ends up in a public PR.
      throw const _Temporary('could not reach the model server');
    }

    final status = response.statusCode;
    if (status != 200) {
      await response.stream.drain<void>();
      if (status == 400 && schema != null) throw const _SchemaRejected();
      final message = 'the model server answered HTTP $status';
      if (status >= 500 || status == 429) throw _Temporary(message);
      throw ReviewModelException(message);
    }
    return await _readStream(response.stream);
  }

  Future<ModelReply> _readStream(Stream<List<int>> body) async {
    final text = StringBuffer();
    int? promptTokens;
    int? completionTokens;

    try {
      final lines = body
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (!line.startsWith('data:')) continue;
        final data = line.substring(5).trim();
        if (data == '[DONE]') break;

        final Object? chunk;
        try {
          chunk = jsonDecode(data);
        } on FormatException {
          continue;
        }
        if (chunk case {'error': final Object _}) {
          throw const ReviewModelException(
            'the model server reported an error while answering',
          );
        }
        if (chunk case {
          'choices': [{'delta': {'content': final String content}}, ...],
        }) {
          text.write(content);
        }
        if (chunk case {
          'usage': {
            'prompt_tokens': final int prompt,
            'completion_tokens': final int completion,
          },
        }) {
          promptTokens = prompt;
          completionTokens = completion;
        }
      }
    } on ReviewModelException {
      rethrow;
    } on Exception {
      throw const _Temporary('the connection dropped while streaming');
    }

    if (text.isEmpty) {
      throw const _Temporary('the model server sent an empty answer');
    }
    return ModelReply(
      text.toString(),
      promptTokens: promptTokens,
      completionTokens: completionTokens,
    );
  }
}

class _Temporary implements Exception {
  const new(this.message);

  final String message;
}

class _SchemaRejected implements Exception {
  const new();
}
