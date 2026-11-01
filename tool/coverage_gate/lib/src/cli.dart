import 'dart:io';

import 'package:args/args.dart';
import 'package:coverage_gate/src/package_coverage.dart';
import 'package:coverage_gate/src/report.dart';
import 'package:coverage_gate/src/workspace.dart';
import 'package:path/path.dart' as p;

/// Exit codes: 0 every package passed, 1 one or more failed, 64 wrong usage.
const _usageError = 64;

ArgParser buildArgParser() => ArgParser()
  ..addOption(
    'min',
    defaultsTo: '70',
    help: 'Lowest line coverage, in percent, each package may have.',
  )
  ..addOption(
    'root',
    help: 'The workspace root. Default: the current directory.',
  )
  ..addFlag('help', abbr: 'h', negatable: false);

/// Checks every workspace package's coverage, after its tests wrote
/// `coverage/lcov.info`. Everything from the outside world is passed in, so
/// it can be tested.
int runGate(
  List<String> arguments, {
  required String workingDirectory,
  required StringSink out,
  required StringSink err,
  Map<String, String> environment = const {},
}) {
  final parser = buildArgParser();
  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (error) {
    err
      ..writeln(error.message)
      ..writeln(parser.usage);
    return _usageError;
  }
  if (args.flag('help')) {
    out
      ..writeln('Fails when a workspace package covers too little of its code.')
      ..writeln()
      ..writeln(parser.usage);
    return 0;
  }
  final minimum = double.tryParse(args.option('min')!);
  if (minimum == null || minimum < 0 || minimum > 100) {
    err.writeln('--min must be a number from 0 to 100.');
    return _usageError;
  }

  final List<PackageCoverage> packages;
  try {
    final root = _realPath(args.option('root') ?? workingDirectory);
    packages = [
      for (final package in workspacePackages(root))
        measurePackage(root: root, package: package),
    ];
  } on FileSystemException catch (error) {
    err.writeln('${error.message}: ${error.path}');
    return _usageError;
  } on FormatException catch (error) {
    err.writeln(error.message);
    return _usageError;
  }

  final report = markdownReport(packages, minimum);
  out.write(report);
  // On GitHub, the table also goes on the run's summary page.
  final summary = environment['GITHUB_STEP_SUMMARY'];
  if (summary != null && summary.isNotEmpty) {
    File(summary).writeAsStringSync(report, mode: FileMode.append);
  }

  final failed = [
    for (final package in packages)
      if (package.resultFor(minimum) == CoverageResult.failed) package.package,
  ];
  if (failed.isEmpty) return 0;
  final message = 'Coverage below the minimum in: ${failed.join(', ')}';
  err.writeln(message);
  if (environment['GITHUB_ACTIONS'] == 'true') out.writeln('::error::$message');
  return 1;
}

/// Absolute, with symbolic links resolved, to match the paths in reports.
String _realPath(String path) =>
    Directory(p.absolute(path)).resolveSymbolicLinksSync();
