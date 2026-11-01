import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// A throwaway workspace on disk, deleted after the test.
class TempWorkspace {
  new()
    : root = Directory.systemTemp
          .createTempSync('coverage_gate_')
          .resolveSymbolicLinksSync() {
    addTearDown(() => Directory(root).deleteSync(recursive: true));
  }

  /// Absolute, with symbolic links resolved, as the gate expects.
  final String root;

  void write(String path, String content) {
    File(p.join(root, path))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  void pubspec(List<String> packages) => write(
    'pubspec.yaml',
    'name: workspace\nworkspace:\n'
        '${packages.map((package) => '  - $package\n').join()}',
  );

  /// A source file with code, so it needs a test.
  void code(String path) => write(path, 'int answer() => 42;\n');

  String absolute(String path) => p.join(root, path);
}

/// One lcov record: a line per entry in [hits], with that many hits.
String lcovRecord(String path, List<int> hits) => [
  'SF:$path',
  for (final (index, count) in hits.indexed) 'DA:${index + 1},$count',
  'LF:${hits.length}',
  'end_of_record',
].join('\n');
