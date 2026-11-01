import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group(AppPage, () {
    testWidgets('keeps its content to a readable width', (tester) async {
      await tester.pumpApp(
        const AppPage(
          child: SizedBox(
            key: Key('content'),
            width: double.infinity,
            height: 10,
          ),
        ),
        size: TestWindows.tablet,
      );

      final width = tester.getSize(find.byKey(const Key('content'))).width;
      expect(width, AppSizes.maxContentWidth - 2 * AppSpacing.lg);
    });
  });

  group(AppListDetailLayout, () {
    const list = Text('list');
    const detail = Text('detail');
    const empty = Text('pick one');

    testWidgets('on a phone, shows the list until something is picked', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppListDetailLayout(list: list, emptyDetail: empty),
        size: TestWindows.phone,
      );

      expect(find.text('list'), findsOneWidget);
      expect(find.text('pick one'), findsNothing);
    });

    testWidgets('on a phone, shows only the detail once picked', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppListDetailLayout(list: list, detail: detail),
        size: TestWindows.phone,
      );

      expect(find.text('detail'), findsOneWidget);
      expect(find.text('list'), findsNothing);
    });

    testWidgets('on a tablet, shows both panes', (tester) async {
      await tester.pumpApp(
        const AppListDetailLayout(list: list, emptyDetail: empty),
        size: TestWindows.tablet,
      );

      expect(find.text('list'), findsOneWidget);
      expect(find.text('pick one'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);

      await tester.pumpApp(
        const AppListDetailLayout(list: list, detail: detail),
        size: TestWindows.tablet,
      );
      expect(find.text('list'), findsOneWidget);
      expect(find.text('detail'), findsOneWidget);
    });
  });

  group(AppAdaptiveNavigation, () {
    const destinations = [
      AppDestination(
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: 'Users',
      ),
      AppDestination(
        icon: Icons.article_outlined,
        selectedIcon: Icons.article,
        label: 'Posts',
      ),
    ];

    Widget navigation(ValueChanged<int> onSelected) => AppAdaptiveNavigation(
      destinations: destinations,
      selectedIndex: 0,
      onSelected: onSelected,
      body: const Text('body'),
    );

    testWidgets('is a bottom bar on a phone', (tester) async {
      int? picked;
      await tester.pumpApp(
        navigation((index) => picked = index),
        size: TestWindows.phone,
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('body'), findsOneWidget);

      await tester.tap(find.text('Posts'));
      expect(picked, 1);
    });

    testWidgets('is a rail on a tablet', (tester) async {
      int? picked;
      await tester.pumpApp(
        navigation((index) => picked = index),
        size: TestWindows.tablet,
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.text('Posts'));
      expect(picked, 1);
    });
  });
}
