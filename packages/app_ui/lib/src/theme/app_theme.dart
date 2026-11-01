import 'package:app_ui/src/brand/app_brand.dart';
import 'package:app_ui/src/foundation/app_colors.dart';
import 'package:app_ui/src/foundation/app_radius.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:flutter/material.dart';

/// The complete Material 3 theme, built from an [AppBrand].
///
/// Every component theme the app uses is set here, so even a raw Material
/// widget matches the design.
abstract final class AppTheme {
  static ThemeData light(AppBrand brand) => _build(brand, Brightness.light);

  static ThemeData dark(AppBrand brand) => _build(brand, Brightness.dark);

  static ThemeData _build(AppBrand brand, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brand.seed,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, fontFamily: brand.fontFamily);
    final text = base.textTheme;

    return base.copyWith(
      extensions: [AppColors.from(scheme, brand)],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: AppInsets.listItem,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        iconColor: scheme.onSurfaceVariant,
        selectedColor: scheme.onSecondaryContainer,
        selectedTileColor: scheme.secondaryContainer,
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
