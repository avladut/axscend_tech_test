/// Fetches decoded JSON from a backend path, such as `/users/1/posts`.
///
/// Implementations throw only `DataFailure`s, never `http` exceptions or
/// `FormatException`s.
abstract interface class JsonClient {
  /// `refresh: true` skips any cache and asks the backend again.
  Future<Object?> get(String path, {bool refresh = false});
}
