import 'package:coverage_gate/coverage_gate.dart';
import 'package:test/test.dart';

import 'support/temp_workspace.dart';

void main() {
  group('measurePackage', () {
    late TempWorkspace workspace;

    setUp(() => workspace = TempWorkspace());

    PackageCoverage measure([String package = 'packages/data']) =>
        measurePackage(root: workspace.root, package: package);

    test("counts only the package's own lib files", () {
      workspace
        ..code('packages/data/lib/a.dart')
        ..write(
          'packages/data/coverage/lcov.info',
          [
            lcovRecord(workspace.absolute('packages/data/lib/a.dart'), [1, 0]),
            // A dependency, and a test file: neither counts.
            lcovRecord(workspace.absolute('packages/domain/lib/b.dart'), [0]),
            lcovRecord(workspace.absolute('packages/data/test/a_test.dart'), [
              0,
            ]),
          ].join('\n'),
        );

      final coverage = measure();

      expect((coverage.linesHit, coverage.linesFound), (1, 2));
      expect(coverage.hasCode, isTrue);
    });

    test('reads the relative paths flutter test writes', () {
      workspace
        ..code('apps/app/lib/main.dart')
        ..write(
          'apps/app/coverage/lcov.info',
          lcovRecord('lib/main.dart', [1, 1, 1]),
        );

      final coverage = measure('apps/app');

      expect((coverage.linesHit, coverage.linesFound), (3, 3));
    });

    test('skips generated files, reported or not', () {
      workspace
        ..code('packages/data/lib/router.g.dart')
        ..write(
          'packages/data/coverage/lcov.info',
          lcovRecord(workspace.absolute('packages/data/lib/router.g.dart'), [
            0,
          ]),
        );

      final coverage = measure();

      expect(coverage.linesFound, 0);
      expect(coverage.hasCode, isFalse);
    });

    test('without a report, a package with code has nothing covered', () {
      workspace.code('packages/data/lib/a.dart');

      final coverage = measure();

      expect(coverage.linesFound, 0);
      expect(coverage.resultFor(70), CoverageResult.failed);
    });

    test('a package with only a barrel file has no code yet', () {
      workspace.write('packages/ui/lib/ui.dart', '/// Soon.\nlibrary;\n');

      expect(measure('packages/ui').resultFor(70), CoverageResult.noCode);
    });
  });

  group('PackageCoverage.resultFor', () {
    PackageCoverage coverage(int hit, int found, {bool hasCode = true}) =>
        PackageCoverage(
          package: 'packages/data',
          linesFound: found,
          linesHit: hit,
          hasCode: hasCode,
        );

    test('passes at exactly the minimum', () {
      expect(coverage(7, 10).resultFor(70), CoverageResult.passed);
    });

    test('fails below it', () {
      expect(coverage(69, 100).resultFor(70), CoverageResult.failed);
    });

    test('fails with code but nothing covered, even at a 0% minimum', () {
      expect(coverage(0, 0).resultFor(0), CoverageResult.failed);
    });

    test('has no result without code', () {
      final empty = coverage(0, 0, hasCode: false);

      expect(empty.resultFor(70), CoverageResult.noCode);
      expect(empty.percent, 0);
    });
  });
}
