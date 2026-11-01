import 'package:flutter/foundation.dart';

/// One option of a choice: the value the app gets back, and its label.
@immutable
class AppChoice<T> {
  const new({required this.value, required this.label});

  final T value;
  final String label;
}
