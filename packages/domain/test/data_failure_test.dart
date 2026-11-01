import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// How the app will use failures: an exhaustive `switch`. Adding a case to
/// `DataFailure` without handling it here stops this test compiling.
String describe(DataFailure failure) => switch (failure) {
  OfflineFailure() => 'offline',
  NotFoundFailure() => 'not found',
  ServerFailure(:final statusCode) => 'server error $statusCode',
  UnexpectedDataFailure() => 'unexpected data',
};

void main() {
  group(DataFailure, () {
    test('every case is a DataFailure the app can tell apart', () {
      const failures = <DataFailure>[
        OfflineFailure(),
        NotFoundFailure(),
        ServerFailure(503),
        UnexpectedDataFailure(),
      ];

      expect(failures, everyElement(isA<Exception>()));
      expect(failures.map(describe), [
        'offline',
        'not found',
        'server error 503',
        'unexpected data',
      ]);
    });

    test('detail is optional and kept for logs', () {
      expect(const OfflineFailure().detail, isNull);
      expect(
        const UnexpectedDataFailure(detail: 'id is not an int').detail,
        'id is not an int',
      );
    });

    test('ServerFailure keeps its status code and detail', () {
      const failure = ServerFailure(500, detail: 'GET /users');

      expect(failure.statusCode, 500);
      expect(failure.detail, 'GET /users');
    });

    test('compares by type and values', () {
      expect(const ServerFailure(500), const ServerFailure(500));
      expect(const ServerFailure(500), isNot(const ServerFailure(502)));
      expect(
        const OfflineFailure(detail: 'timeout'),
        isNot(const OfflineFailure(detail: 'no route')),
      );
      // Same fields, different case.
      expect(const OfflineFailure(), isNot(const NotFoundFailure()));
    });

    test('toString names the case and its values, for logs', () {
      expect(
        const ServerFailure(500, detail: 'GET /users').toString(),
        allOf(
          contains('ServerFailure'),
          contains('500'),
          contains('GET /users'),
        ),
      );
      expect(const NotFoundFailure().toString(), contains('NotFoundFailure'));
    });
  });
}
