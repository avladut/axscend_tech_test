import 'package:flutter/widgets.dart';

/// The spacing scale, on a 4-point rhythm. Use these for every gap and
/// padding, never raw numbers.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Paddings that recur, built from [AppSpacing].
abstract final class AppInsets {
  /// Around a page's content.
  static const page = EdgeInsets.all(AppSpacing.lg);

  /// Inside a card.
  static const card = EdgeInsets.all(AppSpacing.lg);

  /// Around a row in a list.
  static const listItem = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.xs,
  );

  /// Between a page's edge and a section header.
  static const section = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.xl,
    AppSpacing.lg,
    AppSpacing.sm,
  );
}
