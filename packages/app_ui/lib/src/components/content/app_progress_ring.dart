import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// How much of something is done, as a ring with the percentage inside.
class AppProgressRing extends StatelessWidget {
  const new({required this.value, required this.semanticLabel, super.key});

  /// From 0 to 1. Values outside are clamped.
  final double value;

  /// What is being measured, such as "Todos done", for screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final percent = '${(clamped * 100).round()}%';
    return Semantics(
      label: semanticLabel,
      value: percent,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: AppSizes.progressRing,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: clamped,
                color: context.appColors.success,
                backgroundColor: context.colors.surfaceContainerHighest,
              ),
              Center(
                child: Text(percent, style: context.textStyles.labelSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
