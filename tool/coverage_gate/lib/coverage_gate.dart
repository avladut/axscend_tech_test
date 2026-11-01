/// Fails CI when a workspace package covers too little of its code.
///
/// Reads each package's `coverage/lcov.info` and counts its own `lib/` files
/// only. A package with code but nothing covered fails too.
library;

export 'src/cli.dart';
export 'src/lcov.dart';
export 'src/package_coverage.dart';
export 'src/report.dart';
export 'src/source_files.dart';
export 'src/workspace.dart';
