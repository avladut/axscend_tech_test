import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group(AppTheme, () {
    test('builds a light and a dark theme from the brand', () {
      final light = AppTheme.light(testBrand);
      final dark = AppTheme.dark(testBrand);

      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
      expect(light.extension<AppColors>(), isNotNull);
      expect(dark.extension<AppColors>(), isNotNull);
    });

    test('a different seed is a different palette: a rebrand is one value', () {
      const other = AppBrand(name: 'Other', seed: Color(0xFFC62828));

      expect(
        AppTheme.light(other).colorScheme.primary,
        isNot(AppTheme.light(testBrand).colorScheme.primary),
      );
    });

    test('uses the brand font and success colour', () {
      const brand = AppBrand(
        name: 'Fonts',
        seed: Color(0xFF00695C),
        success: Color(0xFF00AA00),
        fontFamily: 'Inter',
      );
      final theme = AppTheme.light(brand);

      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(theme.extension<AppColors>()!.success, const Color(0xFF00AA00));
    });

    test('sets the component themes the app relies on', () {
      final theme = AppTheme.light(testBrand);

      expect(theme.cardTheme.elevation, 0);
      expect(theme.dividerTheme.space, 1);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.chipTheme.showCheckmark, isFalse);
      expect(theme.navigationRailTheme.labelType, NavigationRailLabelType.all);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    });
  });

  test('a focused text field gets a primary border', () {
    final theme = AppTheme.light(testBrand);
    final focused =
        theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;

    expect(focused.borderSide.color, theme.colorScheme.primary);
    expect(focused.borderSide.width, 2);
  });

  group(AppColors, () {
    final light = AppColors.from(
      AppTheme.light(testBrand).colorScheme,
      testBrand,
    );
    final dark = AppColors.from(
      AppTheme.dark(testBrand).colorScheme,
      testBrand,
    );

    test('keeps the brand colours on light, and lighter ones on dark', () {
      expect(light.success, testBrand.success);
      expect(light.warning, testBrand.warning);
      expect(dark.success, isNot(testBrand.success));
    });

    test('copyWith replaces only what is given', () {
      final copy = light.copyWith(muted: const Color(0xFF123456));

      expect(copy.muted, const Color(0xFF123456));
      expect(copy.success, light.success);
    });

    test('lerp blends between themes, and keeps itself without another', () {
      expect(light.lerp(dark, 0).success, light.success);
      expect(light.lerp(dark, 1).success, dark.success);
      expect(light.lerp(null, 0.5), same(light));
    });
  });

  group(AppWindowSize, () {
    test('forWidth follows the Material 3 breakpoints', () {
      expect(AppWindowSize.forWidth(599), AppWindowSize.compact);
      expect(AppWindowSize.forWidth(600), AppWindowSize.medium);
      expect(AppWindowSize.forWidth(839), AppWindowSize.medium);
      expect(AppWindowSize.forWidth(840), AppWindowSize.expanded);
      expect(AppWindowSize.compact.isCompact, isTrue);
      expect(AppWindowSize.expanded.isExpanded, isTrue);
    });
  });

  group('AppThemeContext', () {
    testWidgets('reads the theme and the window size', (tester) async {
      late BuildContext captured;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
        size: TestWindows.tablet,
      );

      expect(captured.colors, Theme.of(captured).colorScheme);
      expect(captured.textStyles, Theme.of(captured).textTheme);
      expect(captured.appColors.success, testBrand.success);
      expect(captured.windowSize, AppWindowSize.expanded);
    });

    testWidgets('still gives app colours without the app theme', (
      tester,
    ) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              colors = context.appColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors.muted, isNotNull);
    });
  });
}
