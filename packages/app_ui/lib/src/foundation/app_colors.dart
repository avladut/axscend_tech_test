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
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
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
    // The on- colours come from the same tonal palettes as their
    // backgrounds, so text stays readable (4.5:1 or more) for any brand.
    return AppColors(
      success: dark ? success.primary : brand.success,
      onSuccess: success.onPrimary,
      successContainer: success.primaryContainer,
      onSuccessContainer: success.onPrimaryContainer,
      warning: dark ? warning.primary : brand.warning,
      onWarning: warning.onPrimary,
      warningContainer: warning.primaryContainer,
      onWarningContainer: warning.onPrimaryContainer,
      muted: scheme.onSurfaceVariant,
    );
  }

  final Color success;
  final Color onSuccess;
  final Color successContainer;

  /// Text and icons on [successContainer], such as a "Done" tag.
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;

  /// Text and icons on [warningContainer], such as a "Pending" tag.
  final Color onWarningContainer;

  /// Secondary text: subtitles, captions, counts.
  final Color muted;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? muted,
  }) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
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
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}
