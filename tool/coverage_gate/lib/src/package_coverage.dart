import 'dart:io';

import 'package:coverage_gate/src/lcov.dart';
import 'package:coverage_gate/src/source_files.dart';
import 'package:path/path.dart' as p;

enum CoverageResult { passed, failed, noCode }

/// One workspace package's coverage: its own `lib/` files only.
class PackageCoverage {
  const new({
    required this.package,
    required this.linesFound,
    required this.linesHit,
    required this.hasCode,
  });

  /// Relative to the workspace root, such as `packages/domain`.
  final String package;

  final int linesFound;
  final int linesHit;

  /// Whether `lib/` has any file with more than `library`, `import`,
  /// `export` and `part` lines.
  final bool hasCode;

  double get percent => linesFound == 0 ? 0 : 100 * linesHit / linesFound;

  /// A package with code but nothing covered (no tests, or tests that never
  /// touch `lib/`) fails like any package below the minimum.
  CoverageResult resultFor(double minimum) {
    if (!hasCode) return CoverageResult.noCode;
    return linesFound > 0 && percent >= minimum
        ? CoverageResult.passed
        : CoverageResult.failed;
  }
}

/// Measures [package] (relative to [root]) from its `coverage/lcov.info` and
/// the files in its `lib/`.
///
/// [root] must be absolute, with symbolic links resolved, because `dart test`
/// writes real absolute paths into its reports.
PackageCoverage measurePackage({
  required String root,
  required String package,
}) {
  final directory = p.join(root, package);
  final lib = p.join(directory, 'lib');

  var found = 0;
  var hit = 0;
  final report = File(p.join(directory, 'coverage', 'lcov.info'));
  if (report.existsSync()) {
    for (final file in parseLcov(report.readAsStringSync())) {
      final path = p.normalize(
        p.isAbsolute(file.path) ? file.path : p.join(directory, file.path),
      );
      // Reports can include dependencies; only this package's code counts.
      if (p.isWithin(lib, path) && !isGenerated(path)) {
        found += file.linesFound;
        hit += file.linesHit;
      }
    }
  }

  final libDirectory = Directory(lib);
  final hasCode =
      libDirectory.existsSync() &&
      libDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => !isGenerated(file.path))
          .any((file) => !isDeclarationsOnly(file.readAsStringSync()));

  return PackageCoverage(
    package: package,
    linesFound: found,
    linesHit: hit,
    hasCode: hasCode,
  );
}
