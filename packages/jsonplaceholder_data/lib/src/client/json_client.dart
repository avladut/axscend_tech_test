/// A page of a list as the backend sent it, and how many items the whole
/// list has, when the backend says.
typedef JsonPage = ({Object? json, int? total});

/// Fetches decoded JSON from a backend path, such as `/users/1/posts`.
///
/// Implementations throw only `DataFailure`s, never `http` exceptions or
/// `FormatException`s.
abstract interface class JsonClient {
  /// `refresh: true` skips any cache and asks the backend again.
  Future<Object?> get(String path, {bool refresh = false});

  /// Like [get], for one page of a list the backend pages. [query] holds the
  /// paging, search and sort parameters.
  Future<JsonPage> getPage(
    String path, {
    Map<String, String> query = const {},
    bool refresh = false,
  });
}
