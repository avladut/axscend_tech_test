import 'package:flutter/widgets.dart';

/// Everything that makes the app look like itself.
///
/// Rebranding means passing a different [AppBrand]: every token, the theme
/// and every component derive from it.
@immutable
class AppBrand {
  const new({
    required this.name,
    required this.seed,
    this.success = const Color(0xFF2E7D32),
    this.warning = const Color(0xFFB26A00),
    this.fontFamily,
  });

  /// The product name, for window titles and headers.
  final String name;

  /// The colour Material 3 builds the whole light and dark palettes from.
  final Color seed;

  /// Done, complete, healthy.
  final Color success;

  /// Pending, needs attention.
  final Color warning;

  /// Null uses the platform font.
  final String? fontFamily;
}
