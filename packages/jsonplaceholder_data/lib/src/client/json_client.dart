/// A page of a list, as `parse` made it (or the decoded JSON), and how
/// many items the whole list has.
typedef JsonPage<T> = ({T json, int total});

/// Fetches JSON from a backend path, such as `/users/1/posts`.
///
/// `parse` turns the decoded JSON into what the caller needs, and throws an
/// `UnexpectedDataFailure` when it doesn't fit. A cache keeps only answers
/// that parse, so one malformed answer can't replace a good one. Without
/// `parse`, the decoded JSON comes back as it is.
///
/// Implementations throw only `DataFailure`s, never `http` exceptions or
/// `FormatException`s.
abstract interface class JsonClient {
  /// `refresh: true` skips any cache and asks the backend again.
  Future<T> get<T>(
    String path, {
    T Function(Object? json)? parse,
    bool refresh = false,
  });

  /// Like [get], for one page of a list the backend pages. [query] holds the
  /// paging, search and sort parameters. Throws an `UnexpectedDataFailure`
  /// when the backend doesn't say how long the whole list is.
  Future<JsonPage<T>> getPage<T>(
    String path, {
    Map<String, String> query = const {},
    T Function(Object? json)? parse,
    bool refresh = false,
  });
}

/// [json] through [parse], or as it is without one.
T parseWith<T>(Object? json, T Function(Object? json)? parse) =>
    parse == null ? json as T : parse(json);
