import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// A task with its done state, read-only. Done tasks are ticked, muted and
/// struck through.
class AppCheckRow extends StatelessWidget {
  const new({required this.title, required this.done, super.key});

  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final style = context.textStyles.bodyLarge;
    return MergeSemantics(
      child: Semantics(
        checked: done,
        child: Padding(
          padding: AppInsets.listItem,
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? appColors.success : appColors.muted,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    title,
                    style: done
                        ? style?.copyWith(
                            color: appColors.muted,
                            decoration: TextDecoration.lineThrough,
                          )
                        : style,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
