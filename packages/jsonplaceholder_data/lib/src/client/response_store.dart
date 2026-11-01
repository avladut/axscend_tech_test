/// Keeps the last good answer for each request.
///
/// Asynchronous, so a store that survives restarts (files, a database) fits
/// the same interface.
abstract interface class ResponseStore {
  /// The saved answer for [key], or null when there is none.
  Future<Object?> read(String key);

  Future<void> write(String key, Object json);
}

/// Remembers answers until the app closes.
class InMemoryResponseStore implements ResponseStore {
  final _answers = <String, Object>{};

  @override
  Future<Object?> read(String key) => Future.value(_answers[key]);

  @override
  Future<void> write(String key, Object json) {
    _answers[key] = json;
    return Future.value();
  }
}
