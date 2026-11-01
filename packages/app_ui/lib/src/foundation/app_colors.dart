import 'package:app_ui/src/brand/app_brand.dart';
import 'package:flutter/material.dart';

/// The colours `ColorScheme` doesn't have, as a theme extension.
///
/// Everything else comes from `context.colors` (the Material 3 scheme).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const new({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.muted,
  });

  /// Derived from [brand] for the [scheme]'s brightness.
  factory from(ColorScheme scheme, AppBrand brand) {
    final dark = scheme.brightness == Brightness.dark;
    final success = ColorScheme.fromSeed(
      seedColor: brand.success,
      brightness: scheme.brightness,
    );
    final warning = ColorScheme.fromSeed(
      seedColor: brand.warning,
      brightness: scheme.brightness,
    );
    return AppColors(
      success: dark ? success.primary : brand.success,
      onSuccess: dark ? success.onPrimary : Colors.white,
      successContainer: success.primaryContainer,
      warning: dark ? warning.primary : brand.warning,
      onWarning: dark ? warning.onPrimary : Colors.white,
      warningContainer: warning.primaryContainer,
      muted: scheme.onSurfaceVariant,
    );
  }

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;

  /// Secondary text: subtitles, captions, counts.
  final Color muted;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? muted,
  }) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    muted: muted ?? this.muted,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}
