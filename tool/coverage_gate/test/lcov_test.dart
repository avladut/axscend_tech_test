import 'package:coverage_gate/coverage_gate.dart';
import 'package:test/test.dart';

void main() {
  group('parseLcov', () {
    test('counts found and hit lines per file', () {
      final files = parseLcov('''
SF:/repo/packages/domain/lib/a.dart
DA:1,1
DA:2,0
DA:3,4
end_of_record
SF:lib/main.dart
DA:7,0
end_of_record
''');

      expect(files.map((file) => file.path), [
        '/repo/packages/domain/lib/a.dart',
        'lib/main.dart',
      ]);
      expect(files.map((file) => (file.linesFound, file.linesHit)), [
        (3, 2),
        (1, 0),
      ]);
    });

    test('counts DA lines itself, whatever LF and LH say', () {
      final file = parseLcov('SF:a.dart\nDA:1,1\nLF:9\nLH:9\nend_of_record');

      expect((file.single.linesFound, file.single.linesHit), (1, 1));
    });

    test('ignores a record without an end, and odd lines', () {
      expect(parseLcov('SF:a.dart\nDA:1,1\n'), isEmpty);
      expect(
        parseLcov('DA:1,1\nSF:a.dart\nDA:2\nend_of_record').single.linesHit,
        0,
      );
    });
  });
}
