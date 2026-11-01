import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

enum _Filter { all, done, pending }

const List<AppChoice<_Filter>> _choices = [
  AppChoice(value: _Filter.all, label: 'All'),
  AppChoice(value: _Filter.done, label: 'Done'),
  AppChoice(value: _Filter.pending, label: 'Pending'),
];

void main() {
  group(AppChoiceChips, () {
    testWidgets('selects one chip and reports the pick', (tester) async {
      _Filter? picked;
      await tester.pumpApp(
        AppChoiceChips<_Filter>(
          choices: _choices,
          selected: _Filter.done,
          onSelected: (value) => picked = value,
        ),
      );

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips.map((chip) => chip.selected), [false, true, false]);

      await tester.tap(find.text('Pending'));
      expect(picked, _Filter.pending);
    });
  });

  group(AppSortButton, () {
    testWidgets('lists the orders with the current one ticked', (tester) async {
      _Filter? picked;
      await tester.pumpApp(
        AppSortButton<_Filter>(
          choices: _choices,
          selected: _Filter.all,
          onSelected: (value) => picked = value,
          tooltip: 'Sort',
        ),
      );

      expect(find.byTooltip('Sort'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // The current order is ticked, the others aren't.
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(PopupMenuItem<_Filter>, 'All'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(picked, _Filter.done);
    });
  });

  group(AppSearchField, () {
    testWidgets('reports typing, and clears with its button', (tester) async {
      final changes = <String>[];
      await tester.pumpApp(
        AppSearchField(
          hint: 'Search users',
          clearTooltip: 'Clear search',
          onChanged: changes.add,
        ),
      );

      expect(find.text('Search users'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);

      await tester.enterText(find.byType(TextField), 'lea');
      await tester.pump();
      expect(changes, ['lea']);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      expect(changes, ['lea', '']);
      expect(find.text('lea'), findsNothing);
      expect(find.byTooltip('Clear search'), findsNothing);
    });

    testWidgets('starts with its value', (tester) async {
      await tester.pumpApp(
        AppSearchField(
          hint: 'Search',
          clearTooltip: 'Clear',
          value: 'bret',
          onChanged: (_) {},
        ),
      );

      expect(find.text('bret'), findsOneWidget);
      expect(find.byTooltip('Clear'), findsOneWidget);
    });

    testWidgets('follows a value changed from outside', (tester) async {
      Widget field(String value) => AppSearchField(
        hint: 'Search',
        clearTooltip: 'Clear',
        value: value,
        onChanged: (_) {},
      );

      await tester.pumpApp(field('bret'));
      await tester.pumpApp(field(''));

      expect(find.text('bret'), findsNothing);
      expect(find.byTooltip('Clear'), findsNothing);
    });

    testWidgets('puts the cursor at the end of a text replaced from outside', (
      tester,
    ) async {
      Widget field(String value) => AppSearchField(
        hint: 'Search',
        clearTooltip: 'Clear',
        value: value,
        onChanged: (_) {},
      );

      await tester.pumpApp(field('bret'));
      await tester.pumpApp(field('leanne'));

      final controller = tester
          .widget<TextField>(find.byType(TextField))
          .controller!;
      expect(controller.text, 'leanne');
      expect(controller.selection, const TextSelection.collapsed(offset: 6));
    });

    testWidgets('keeps the cursor when the parent echoes what was typed', (
      tester,
    ) async {
      var value = '';
      late StateSetter rebuild;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return AppSearchField(
              hint: 'Search',
              clearTooltip: 'Clear',
              value: value,
              onChanged: (text) => rebuild(() => value = text),
            );
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'leanne');
      // Move the cursor to the middle, then have the parent echo the text.
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection.collapsed(offset: 3);
      rebuild(() => value = 'leanne');
      await tester.pump();

      expect(field.controller!.selection.baseOffset, 3);
      expect(field.controller!.text, 'leanne');
    });
  });
}
