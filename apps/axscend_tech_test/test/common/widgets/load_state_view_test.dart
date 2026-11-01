import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LoadStateView, () {
    var retries = 0;
    setUp(() => retries = 0);

    Future<void> pumpView(WidgetTester tester, LoadState<String> state) =>
        tester.pumpApp(
          Scaffold(
            body: LoadStateView(
              state: state,
              loadingTitle: 'Loading things…',
              onRetry: () => retries++,
              builder: (context, data) => Text('Got $data'),
            ),
          ),
        );

    testWidgets('shows a spinner until the data first arrives', (tester) async {
      await pumpView(tester, const LoadState(status: LoadStatus.loading));

      expect(find.text('Loading things…'), findsOneWidget);
    });

    testWidgets('shows the data, also while it refreshes', (tester) async {
      await pumpView(
        tester,
        const LoadState(status: LoadStatus.loading, data: 'a'),
      );

      expect(find.text('Got a'), findsOneWidget);
    });

    testWidgets('explains a failure and tries again', (tester) async {
      await pumpView(
        tester,
        const LoadState(
          status: LoadStatus.failure,
          data: 'a',
          failure: OfflineFailure(),
        ),
      );

      expect(find.text(l10n.failureOfflineTitle), findsOneWidget);
      await tester.tap(find.text(l10n.tryAgain));
      expect(retries, 1);
    });
  });
}
