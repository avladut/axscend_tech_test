import 'package:axscend_tech_test/common/widgets/data_failure_view.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(DataFailureView, () {
    testWidgets('explains the failure and tries again', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        Scaffold(
          body: DataFailureView(
            failure: const ServerFailure(500),
            onRetry: () => retries++,
          ),
        ),
      );

      expect(find.text(l10n.failureServerTitle), findsOneWidget);
      expect(find.text(l10n.failureServerMessage(500)), findsOneWidget);
      await tester.tap(find.text(l10n.tryAgain));
      expect(retries, 1);
    });

    testWidgets('offers no retry for something that is gone', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: DataFailureView(
            failure: const NotFoundFailure(),
            onRetry: () {},
          ),
        ),
      );

      expect(find.text(l10n.failureNotFoundTitle), findsOneWidget);
      expect(find.text(l10n.tryAgain), findsNothing);
    });
  });
}
