import 'package:domain/domain.dart';

/// The failure for [json] that isn't the [what] the API documents. The
/// detail shows the start of the JSON, for logs.
UnexpectedDataFailure invalidJson(String what, Object? json) {
  final text = '$json';
  final shown = text.length > 200 ? '${text.substring(0, 200)}…' : text;
  return UnexpectedDataFailure(detail: 'Not a valid $what: $shown');
}

/// Parses a JSON list item by item with [parse].
List<T> parseList<T>(
  Object? json,
  String what,
  T Function(Object? item) parse,
) {
  if (json is! List<Object?>) throw invalidJson('list of ${what}s', json);
  return [for (final item in json) parse(item)];
}
