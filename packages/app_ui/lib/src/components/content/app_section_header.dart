import 'package:app_ui/src/components/content/app_tag.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// The title above a group of items, with an optional count and action.
class AppSectionHeader extends StatelessWidget {
  const new({required this.title, this.count, this.trailing, super.key});

  final String title;

  /// Shown as a tag next to the title.
  final int? count;

  /// Such as a sort button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final trailing = this.trailing;
    return Padding(
      padding: AppInsets.section,
      child: Row(
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(title, style: context.textStyles.titleMedium),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            AppTag(label: '$count'),
          ],
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }
}
