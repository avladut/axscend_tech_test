import 'dart:async';
import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:jsonplaceholder_data/src/client/json_client.dart';

/// Talks to the backend over HTTP. Every way a request can go wrong becomes
/// a [DataFailure].
class HttpJsonClient implements JsonClient {
  new({
    http.Client? client,
    Uri? baseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl ?? defaultBaseUrl;

  static final Uri defaultBaseUrl = Uri.parse(
    'https://jsonplaceholder.typicode.com',
  );

  final Uri baseUrl;
  final Duration timeout;
  final http.Client _client;

  /// Always asks the backend: there is no cache at this level, so `refresh`
  /// changes nothing.
  @override
  Future<Object?> get(String path, {bool refresh = false}) async {
    final base = baseUrl.path.endsWith('/')
        ? baseUrl.path.substring(0, baseUrl.path.length - 1)
        : baseUrl.path;
    final uri = baseUrl.replace(path: '$base$path');

    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw OfflineFailure(
        detail: 'GET $path timed out after ${timeout.inMilliseconds} ms',
      );
    } on http.ClientException catch (error) {
      throw OfflineFailure(detail: 'GET $path: ${error.message}');
    } on Exception catch (error) {
      // http wraps socket and HTTP errors, but not every transport error
      // (a failed TLS handshake, for one). All of them mean "can't reach it".
      // Errors (bugs) aren't caught. The type goes in the detail for logs.
      throw OfflineFailure(detail: 'GET $path: ${error.runtimeType}: $error');
    }

    final status = response.statusCode;
    if (status == 404) throw NotFoundFailure(detail: 'GET $path');
    if (status < 200 || status >= 300) {
      throw ServerFailure(status, detail: 'GET $path');
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw UnexpectedDataFailure(detail: 'GET $path: the body is not JSON');
    }
  }
}
