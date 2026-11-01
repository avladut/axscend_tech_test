import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// The workspace's packages, from the `workspace:` list in the root
/// `pubspec.yaml`, so a new package can't be missed.
List<String> workspacePackages(String root) {
  final file = File(p.join(root, 'pubspec.yaml'));
  if (!file.existsSync()) {
    throw FormatException('No pubspec.yaml in $root.');
  }
  if (loadYaml(file.readAsStringSync()) case {
    'workspace': final List<Object?> packages,
  }) {
    return [for (final package in packages) '$package'];
  }
  throw FormatException('The pubspec.yaml in $root has no workspace: list.');
}
