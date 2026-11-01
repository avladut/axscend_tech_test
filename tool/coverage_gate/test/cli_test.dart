import 'dart:io';

import 'package:coverage_gate/coverage_gate.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/temp_workspace.dart';

void main() {
  group('runGate', () {
    late TempWorkspace workspace;
    late StringBuffer out;
    late StringBuffer err;

    setUp(() {
      workspace = TempWorkspace();
      workspace
        ..pubspec(['packages/domain', 'apps/app', 'packages/ui'])
        ..code('packages/domain/lib/a.dart')
        ..write(
          'packages/domain/coverage/lcov.info',
          lcovRecord(workspace.absolute('packages/domain/lib/a.dart'), [
            1,
            1,
            1,
            0,
          ]),
        )
        ..code('apps/app/lib/main.dart')
        ..write(
          'apps/app/coverage/lcov.info',
          lcovRecord('lib/main.dart', [1, 1]),
        )
        ..write('packages/ui/lib/ui.dart', 'library;\n');
      out = StringBuffer();
      err = StringBuffer();
    });

    int run(
      List<String> arguments, [
      Map<String, String> environment = const {},
    ]) => runGate(
      arguments,
      workingDirectory: workspace.root,
      out: out,
      err: err,
      environment: environment,
    );

    test('passes when every package reaches the minimum', () {
      expect(run(const []), 0, reason: err.toString());
      expect(out.toString(), contains('| `packages/domain` | 3/4 | 75% |'));
      expect(out.toString(), contains('⏭️ no code yet'));
    });

    test('fails when one package is below the minimum', () {
      expect(run(const ['--min', '80']), 1);
      expect(err.toString(), contains('packages/domain'));
      expect(err.toString(), isNot(contains('apps/app')));
    });

    test('fails when a package with code has no tests', () {
      workspace
        ..pubspec(['packages/domain', 'apps/app', 'packages/forms'])
        ..code('packages/forms/lib/form.dart');

      expect(run(const []), 1);
      expect(err.toString(), contains('packages/forms'));
    });

    test('on GitHub, adds the table to the summary and annotates failures', () {
      final summary = p.join(workspace.root, 'summary.md');
      File(summary).writeAsStringSync('# Earlier steps\n');

      final code = run(
        const ['--min', '80'],
        {'GITHUB_ACTIONS': 'true', 'GITHUB_STEP_SUMMARY': summary},
      );

      expect(code, 1);
      final written = File(summary).readAsStringSync();
      expect(written, startsWith('# Earlier steps\n### Test coverage'));
      expect(out.toString(), contains('::error::Coverage below the minimum'));
    });

    test('reads every package from the root pubspec', () {
      workspace.pubspec(['packages/domain']);

      run(const []);

      expect(out.toString(), isNot(contains('apps/app')));
    });

    test('rejects a bad --min, and a root without a workspace', () {
      expect(run(const ['--min', 'lots']), 64);
      expect(run(const ['--min', '101']), 64);

      workspace.write('pubspec.yaml', 'name: not_a_workspace\n');
      expect(run(const []), 64);
      expect(err.toString(), contains('no workspace: list'));

      expect(run(['--root', p.join(workspace.root, 'missing')]), 64);
    });
  });
}
