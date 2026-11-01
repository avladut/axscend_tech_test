import 'package:app_ui/app_ui.dart';
import 'package:app_ui/testing.dart';
import 'package:axscend_tech_test/app/brand.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

/// Window sizes, one per size class.
abstract final class TestWindows {
  static const phone = Size(390, 844);
  static const tablet = Size(1024, 768);
}

/// Records where a screen navigates, instead of navigating.
class MockGoRouter extends Mock implements GoRouter;

extension PumpApp on WidgetTester {
  /// Pumps [widget] with the app's theme and English translations, and a
  /// fake picture cache (tests have no network or disk). Optionally in a
  /// window of [size], and with a [router] to record navigation.
  Future<void> pumpApp(Widget widget, {Size? size, GoRouter? router}) async {
    if (size != null) {
      view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(view.reset);
    }
    final home = AppImageCacheScope(cache: FakeImageCache(), child: widget);
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(appBrand),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: router == null
            ? home
            : InheritedGoRouter(goRouter: router, child: home),
      ),
    );
  }
}

/// The English translations, for expected texts.
AppLocalizations get l10n => lookupAppLocalizations(const Locale('en'));
