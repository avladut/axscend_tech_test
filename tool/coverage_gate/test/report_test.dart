import 'package:coverage_gate/coverage_gate.dart';
import 'package:test/test.dart';

void main() {
  test('markdownReport shows a row per package, with its verdict', () {
    final report = markdownReport(const [
      PackageCoverage(
        package: 'packages/domain',
        linesFound: 45,
        linesHit: 45,
        hasCode: true,
      ),
      PackageCoverage(
        package: 'packages/data',
        linesFound: 214,
        linesHit: 210,
        hasCode: true,
      ),
      PackageCoverage(
        package: 'apps/app',
        linesFound: 10,
        linesHit: 5,
        hasCode: true,
      ),
      PackageCoverage(
        package: 'packages/forms',
        linesFound: 0,
        linesHit: 0,
        hasCode: true,
      ),
      PackageCoverage(
        package: 'packages/ui',
        linesFound: 0,
        linesHit: 0,
        hasCode: false,
      ),
    ], 70);

    expect(
      report,
      startsWith('### Test coverage (at least 70% of lines, per package)'),
    );
    expect(report, contains('| `packages/domain` | 45/45 | 100% | ✅ passed |'));
    expect(
      report,
      contains('| `packages/data` | 210/214 | 98.1% | ✅ passed |'),
    );
    expect(report, contains('| `apps/app` | 5/10 | 50% | ❌ below 70% |'));
    expect(
      report,
      contains('| `packages/forms` | - | - | ❌ no coverage: no tests? |'),
    );
    expect(report, contains('| `packages/ui` | - | - | ⏭️ no code yet |'));
  });
}
