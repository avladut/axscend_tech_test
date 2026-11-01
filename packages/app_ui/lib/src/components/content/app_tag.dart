import 'package:app_ui/src/foundation/app_radius.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:app_ui/src/foundation/app_tone.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// A small label in a pill: a count, or a status such as "Done". The [tone]
/// picks its colours.
class AppTag extends StatelessWidget {
  const new({required this.label, this.tone = AppTone.neutral, super.key});

  final String label;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appColors = context.appColors;
    final (background, foreground) = switch (tone) {
      AppTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      AppTone.brand => (colors.primaryContainer, colors.onPrimaryContainer),
      AppTone.success => (appColors.successContainer, appColors.success),
      AppTone.warning => (appColors.warningContainer, appColors.warning),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderSm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: context.textStyles.labelMedium?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
