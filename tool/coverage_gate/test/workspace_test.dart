import 'package:coverage_gate/coverage_gate.dart';
import 'package:test/test.dart';

import 'support/temp_workspace.dart';

void main() {
  group('workspacePackages', () {
    test('lists the packages in the root pubspec', () {
      final workspace = TempWorkspace()..pubspec(['apps/app', 'packages/ui']);

      expect(workspacePackages(workspace.root), ['apps/app', 'packages/ui']);
    });

    test('fails clearly without a pubspec or a workspace list', () {
      final workspace = TempWorkspace();
      expect(
        () => workspacePackages(workspace.root),
        throwsA(isA<FormatException>()),
      );

      workspace.write('pubspec.yaml', 'name: app\n');
      expect(
        () => workspacePackages(workspace.root),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
