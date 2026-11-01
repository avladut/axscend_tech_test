import 'package:app_ui/src/components/controls/app_choice.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:flutter/material.dart';

/// A row of chips where exactly one is selected, such as a filter between
/// "All", "Done" and "Pending".
class AppChoiceChips<T> extends StatelessWidget {
  const new({
    required this.choices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<AppChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final choice in choices)
        ChoiceChip(
          label: Text(choice.label),
          selected: choice.value == selected,
          onSelected: (_) => onSelected(choice.value),
        ),
    ],
  );
}
