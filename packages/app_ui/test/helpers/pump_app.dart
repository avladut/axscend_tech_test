import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const testBrand = AppBrand(name: 'Test', seed: Color(0xFF00695C));

/// Window sizes for the adaptive components: one per size class.
abstract final class TestWindows {
  static const phone = Size(390, 844);
  static const tablet = Size(1024, 768);
}

extension PumpApp on WidgetTester {
  /// Pumps [widget] in a themed page, optionally in a window of [size].
  Future<void> pumpApp(
    Widget widget, {
    Size? size,
    Brightness brightness = Brightness.light,
  }) async {
    if (size != null) {
      view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(view.reset);
    }
    await pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.light
            ? AppTheme.light(testBrand)
            : AppTheme.dark(testBrand),
        home: Scaffold(body: widget),
      ),
    );
  }
}
