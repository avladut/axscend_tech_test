/// Keeps the last good answer for each request.
///
/// Asynchronous, so a store that survives restarts (files, a database) fits
/// the same interface.
abstract interface class ResponseStore {
  /// The saved answer for [key], or null when there is none.
  Future<Object?> read(String key);

  Future<void> write(String key, Object json);
}

/// Remembers the last [maxEntries] answers until the app closes. When it is
/// full, the answer used longest ago is forgotten, so memory stays bounded.
class InMemoryResponseStore implements ResponseStore {
  new({this.maxEntries = 50})
    : assert(maxEntries > 0, 'the store must hold at least one answer');

  final int maxEntries;

  // Kept in order of use: the first key is the one used longest ago.
  final _answers = <String, Object>{};

  /// How many answers are saved.
  int get length => _answers.length;

  @override
  Future<Object?> read(String key) {
    final json = _answers.remove(key);
    if (json != null) _answers[key] = json;
    return Future.value(json);
  }

  @override
  Future<void> write(String key, Object json) {
    _answers
      ..remove(key)
      ..[key] = json;
    if (_answers.length > maxEntries) _answers.remove(_answers.keys.first);
    return Future.value();
  }
}
