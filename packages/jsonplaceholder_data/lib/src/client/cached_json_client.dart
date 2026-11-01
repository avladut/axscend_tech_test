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
class CachedJsonClient implements JsonClient {
  new(this._inner, {ResponseStore? store})
    : _store = store ?? InMemoryResponseStore();

  final JsonClient _inner;
  final ResponseStore _store;

  @override
  Future<Object?> get(String path, {bool refresh = false}) async {
    if (!refresh) {
      final saved = await _store.read(path);
      if (saved != null) return saved;
    }
    try {
      final fresh = await _inner.get(path, refresh: refresh);
      if (fresh != null) await _store.write(path, fresh);
      return fresh;
    } on DataFailure catch (failure) {
      // "Not found" and bad data are real answers. Old data would hide them.
      final canFallBack = failure is OfflineFailure || failure is ServerFailure;
      final saved = canFallBack ? await _store.read(path) : null;
      if (saved == null) rethrow;
      return saved;
    }
  }
}
