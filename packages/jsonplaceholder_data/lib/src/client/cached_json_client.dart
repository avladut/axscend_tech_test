import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/client/response_store.dart';

/// Adds a cache to another [JsonClient] (a decorator), so the repositories
/// never know it exists.
///
/// - A request already answered is served from the [ResponseStore].
/// - `refresh: true` asks the backend again and saves the new answer.
/// - When the backend can't be reached or fails, the last good answer is
///   used instead, if there is one.
/// - A `null` answer isn't saved: the store uses `null` for "nothing saved",
///   so it couldn't be told apart from a miss anyway.
class CachedJsonClient implements JsonClient {
  new(this._inner, {ResponseStore? store})
    : _store = store ?? InMemoryResponseStore();

  final JsonClient _inner;
  final ResponseStore _store;

  @override
  Future<T> get<T>(
    String path, {
    T Function(Object? json)? parse,
    bool refresh = false,
  }) => _cached(
    path,
    refresh,
    fetch: () => _inner.get<Object?>(path, refresh: refresh),
    read: (json) => parseWith(json, parse),
  );

  /// Cached like [get]: each query is saved separately, with its total.
  @override
  Future<JsonPage<T>> getPage<T>(
    String path, {
    Map<String, String> query = const {},
    T Function(Object? json)? parse,
    bool refresh = false,
  }) {
    // Sorted, so the same query always finds the same entry. The prefix
    // keeps it apart from a plain get of the same path.
    final entries = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final sorted = Uri(queryParameters: Map.fromEntries(entries)).query;
    return _cached(
      'page:$path?$sorted',
      refresh,
      fetch: () async {
        final page = await _inner.getPage<Object?>(
          path,
          query: query,
          refresh: refresh,
        );
        return {'json': page.json, 'total': page.total};
      },
      read: (saved) => switch (saved) {
        {'json': final Object? json, 'total': final int total} => (
          json: parseWith(json, parse),
          total: total,
        ),
        _ => throw UnexpectedDataFailure(detail: 'page:$path: not a page'),
      },
    );
  }

  /// The answer for [key]: saved, unless [refresh], or else [fetch]ed. A
  /// fetched answer is [read] (parsed) before it is saved, so one that
  /// doesn't parse throws and never replaces the last good one.
  Future<T> _cached<T>(
    String key,
    bool refresh, {
    required Future<Object?> Function() fetch,
    required T Function(Object? json) read,
  }) async {
    if (!refresh) {
      final saved = await _store.read(key);
      if (saved != null) return read(saved);
    }
    try {
      final fresh = await fetch();
      final result = read(fresh);
      if (fresh != null) await _store.write(key, fresh);
      return result;
    } on DataFailure catch (failure) {
      // "Not found" and bad data are real answers. Old data would hide them.
      final canFallBack = failure is OfflineFailure || failure is ServerFailure;
      final saved = canFallBack ? await _store.read(key) : null;
      if (saved == null) rethrow;
      return read(saved);
    }
  }
}
