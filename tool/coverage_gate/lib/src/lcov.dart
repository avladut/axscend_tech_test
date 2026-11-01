import 'dart:convert';

/// What a coverage report says about one source file.
class FileCoverage {
  const new({
    required this.path,
    required this.linesFound,
    required this.linesHit,
  });

  /// As the report writes it: absolute (`dart test`) or relative to the
  /// package (`flutter test`).
  final String path;

  /// Lines that can run.
  final int linesFound;

  /// Lines a test ran at least once.
  final int linesHit;
}

/// Reads an lcov report.
///
/// Counts the `DA` lines itself instead of trusting `LF`/`LH`, which not
/// every tool writes.
List<FileCoverage> parseLcov(String report) {
  final files = <FileCoverage>[];
  String? path;
  var found = 0;
  var hit = 0;
  for (final line in LineSplitter.split(report).map((line) => line.trim())) {
    if (line.startsWith('SF:')) {
      path = line.substring(3);
      found = 0;
      hit = 0;
    } else if (line.startsWith('DA:') && path != null) {
      found++;
      final hits = line.substring(3).split(',').elementAtOrNull(1);
      if ((int.tryParse(hits ?? '') ?? 0) > 0) hit++;
    } else if (line == 'end_of_record' && path != null) {
      files.add(FileCoverage(path: path, linesFound: found, linesHit: hit));
      path = null;
    }
  }
  return files;
}
