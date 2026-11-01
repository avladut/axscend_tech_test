import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group(AppStatusView, () {
    testWidgets('loading shows a spinner and its title', (tester) async {
      await tester.pumpApp(const AppStatusView.loading(title: 'Loading…'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading…'), findsOneWidget);
    });

    testWidgets('loading works without a title', (tester) async {
      await tester.pumpApp(const AppStatusView.loading());

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('empty shows its title and message, with no button', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppStatusView.empty(
          title: 'No users found',
          message: 'Try another search.',
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No users found'), findsOneWidget);
      expect(find.text('Try another search.'), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('error offers to try again', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        AppStatusView.error(
          title: "You're offline",
          actionLabel: 'Try again',
          onAction: () => retries++,
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('error has no button without an action', (tester) async {
      await tester.pumpApp(
        const AppStatusView.error(title: 'Not found', actionLabel: 'Retry'),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('looks right in the dark theme too', (tester) async {
      await tester.pumpApp(
        const AppStatusView.error(title: 'Not found'),
        brightness: Brightness.dark,
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.cloud_off_outlined));
      expect(icon.color, AppTheme.dark(testBrand).colorScheme.error);
    });
  });
}
