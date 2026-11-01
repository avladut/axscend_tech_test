import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// A list and the item picked from it.
///
/// On expanded windows (tablets) both show side by side, with [emptyDetail]
/// in the second pane until something is picked. On smaller windows only one
/// shows: [detail] when there is one, otherwise [list].
class AppListDetailLayout extends StatelessWidget {
  const new({required this.list, this.detail, this.emptyDetail, super.key});

  final Widget list;
  final Widget? detail;
  final Widget? emptyDetail;

  @override
  Widget build(BuildContext context) {
    if (!context.windowSize.isExpanded) return detail ?? list;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: AppSizes.listPaneWidth, child: list),
        const VerticalDivider(),
        Expanded(child: detail ?? emptyDetail ?? const SizedBox.shrink()),
      ],
    );
  }
}
