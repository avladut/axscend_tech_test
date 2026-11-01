import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/brand.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Window sizes, one per size class.
abstract final class TestWindows {
  static const phone = Size(390, 844);
  static const tablet = Size(1024, 768);
}

extension PumpApp on WidgetTester {
  /// Pumps [widget] with the app's theme and English translations,
  /// optionally in a window of [size].
  Future<void> pumpApp(Widget widget, {Size? size}) async {
    if (size != null) {
      view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(view.reset);
    }
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(appBrand),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}

/// The English translations, for expected texts.
AppLocalizations get l10n => lookupAppLocalizations(const Locale('en'));
