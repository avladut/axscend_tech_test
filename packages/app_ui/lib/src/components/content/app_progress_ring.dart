import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// How much of something is done, as a ring with the percentage inside.
class AppProgressRing extends StatelessWidget {
  const new({required this.value, required this.semanticLabel, super.key});

  /// From 0 to 1. Values outside are clamped, and a value that isn't a
  /// number (such as 0 of 0 done) counts as 0.
  final double value;

  /// What is being measured, such as "Todos done", for screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // clamp alone would turn NaN into 1.0, a full ring.
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
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
