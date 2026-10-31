import 'dart:io';

import 'package:ai_review/ai_review.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runCli(
    arguments,
    environment: Platform.environment,
    out: stdout,
    err: stderr,
  );
}
