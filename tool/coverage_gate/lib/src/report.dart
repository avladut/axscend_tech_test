import 'package:coverage_gate/src/package_coverage.dart';

/// The coverage table, in Markdown, for the log and the run's summary page.
String markdownReport(List<PackageCoverage> packages, double minimum) {
  final limit = _percent(minimum);
  final buffer = StringBuffer()
    ..writeln('### Test coverage (at least $limit of lines, per package)')
    ..writeln()
    ..writeln('| Package | Lines | Coverage | Result |')
    ..writeln('|---|---|---|---|');
  for (final package in packages) {
    final measured = package.linesFound > 0;
    final lines = measured ? '${package.linesHit}/${package.linesFound}' : '-';
    final coverage = measured ? _percent(package.percent) : '-';
    final verdict = switch (package.resultFor(minimum)) {
      CoverageResult.passed => '✅ passed',
      CoverageResult.noCode => '⏭️ no code yet',
      CoverageResult.failed when !measured => '❌ no coverage: no tests?',
      CoverageResult.failed => '❌ below $limit',
    };
    buffer.writeln('| `${package.package}` | $lines | $coverage | $verdict |');
  }
  return buffer.toString();
}

String _percent(double value) =>
    '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}%';
