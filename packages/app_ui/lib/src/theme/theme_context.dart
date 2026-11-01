import 'package:app_ui/src/brand/app_brand.dart';
import 'package:app_ui/src/foundation/app_breakpoints.dart';
import 'package:app_ui/src/foundation/app_colors.dart';
import 'package:flutter/material.dart';

/// How screens and components read the design system.
extension AppThemeContext on BuildContext {
  /// The Material 3 colour scheme built from the brand.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The colours `ColorScheme` lacks. Falls back to a neutral brand when no
  /// app theme is installed, so a bare `MaterialApp` in a test still works.
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ??
      AppColors.from(colors, _fallbackBrand);

  /// The type scale.
  TextTheme get textStyles => Theme.of(this).textTheme;

  /// The window's size class, for adaptive layouts.
  AppWindowSize get windowSize =>
      AppWindowSize.forWidth(MediaQuery.sizeOf(this).width);
}

const _fallbackBrand = AppBrand(name: 'App', seed: Color(0xFF3F51B5));
