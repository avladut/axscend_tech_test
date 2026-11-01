import 'package:axscend_tech_test/common/failures/data_failure_text.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('DataFailureText', () {
    test('puts every failure into words', () {
      expect(const OfflineFailure().describe(l10n), (
        title: l10n.failureOfflineTitle,
        message: l10n.failureOfflineMessage,
      ));
      expect(const NotFoundFailure().describe(l10n), (
        title: l10n.failureNotFoundTitle,
        message: l10n.failureNotFoundMessage,
      ));
      expect(const UnexpectedDataFailure().describe(l10n), (
        title: l10n.failureUnexpectedTitle,
        message: l10n.failureUnexpectedMessage,
      ));
    });

    test("names the server's error code", () {
      final text = const ServerFailure(503).describe(l10n);
      expect(text.title, l10n.failureServerTitle);
      expect(text.message, contains('503'));
    });

    test('never shows the technical detail', () {
      final text = const OfflineFailure(detail: 'SocketException')
          .describe(l10n);
      expect('${text.title} ${text.message}', isNot(contains('Socket')));
    });

    test('offers a retry unless the thing is gone', () {
      expect(const OfflineFailure().canRetry, isTrue);
      expect(const ServerFailure(500).canRetry, isTrue);
      expect(const UnexpectedDataFailure().canRetry, isTrue);
      expect(const NotFoundFailure().canRetry, isFalse);
    });
  });
}
