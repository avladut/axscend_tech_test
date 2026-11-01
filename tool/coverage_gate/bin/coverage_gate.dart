import 'dart:io';

import 'package:coverage_gate/coverage_gate.dart';

void main(List<String> arguments) {
  exitCode = runGate(
    arguments,
    workingDirectory: Directory.current.path,
    out: stdout,
    err: stderr,
    environment: Platform.environment,
  );
}
