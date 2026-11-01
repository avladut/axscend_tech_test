import 'package:app_ui/src/components/controls/app_choice.dart';
import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:flutter/material.dart';

/// A sort icon that opens a menu of orders, with the current one ticked.
class AppSortButton<T> extends StatelessWidget {
  const new({
    required this.choices,
    required this.selected,
    required this.onSelected,
    required this.tooltip,
    super.key,
  });

  final List<AppChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Such as "Sort", for the icon's tooltip and screen readers.
  final String tooltip;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
    tooltip: tooltip,
    icon: const Icon(Icons.sort),
    initialValue: selected,
    onSelected: onSelected,
    // Plain items with a tick: CheckedPopupMenuItem is a ListTile, whose ink
    // the menu's own background would hide.
    itemBuilder: (context) => [
      for (final choice in choices)
        PopupMenuItem<T>(
          value: choice.value,
          child: Semantics(
            selected: choice.value == selected,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: AppSizes.iconMd,
                  child: choice.value == selected
                      ? const Icon(Icons.check, size: AppSizes.iconMd)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(child: Text(choice.label)),
              ],
            ),
          ),
        ),
    ],
  );
}
