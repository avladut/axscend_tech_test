import 'dart:io';

import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

/// Runs against a real, throwaway git repository.
void main() {
  group(GitDiffSource, () {
    late Directory repo;
    late GitDiffSource source;

    Future<String> git(List<String> args) async {
      final result = await Process.run(
        'git',
        args,
        workingDirectory: repo.path,
      );
      if (result.exitCode != 0) fail('git $args: ${result.stderr}');
      return (result.stdout as String).trim();
    }

    Future<String> commit(String file, String content) async {
      File('${repo.path}/$file').writeAsStringSync(content);
      await git(['add', file]);
      await git(['commit', '-q', '-m', 'change $file']);
      return await git(['rev-parse', 'HEAD']);
    }

    setUp(() async {
      repo = Directory.systemTemp.createTempSync('ai_review_git_');
      await git(['init', '-q', '-b', 'main']);
      await git(['config', 'user.email', 'test@example.com']);
      await git(['config', 'user.name', 'Test']);
      await git(['config', 'commit.gpgsign', 'false']);
      source = GitDiffSource(ProcessGitRunner(workingDirectory: repo.path));
    });

    tearDown(() => repo.deleteSync(recursive: true));

    test('diffs a PR against its merge base, not the moved base', () async {
      await commit('a.dart', 'one\n');
      await git(['switch', '-q', '-c', 'feature']);
      await commit('a.dart', 'one\ntwo\n');
      await git(['switch', '-q', 'main']);
      await commit('b.dart', 'only on main\n');

      final files = await source.pullRequestDiff(base: 'main', head: 'feature');

      final file = files.single;
      expect(file.path, 'a.dart');
      expect(file.commentableLines, {1, 2});
    });

    test('diffs only the commits after a given one', () async {
      await commit('a.dart', 'one\n');
      final first = await commit('a.dart', 'one\ntwo\n');
      final second = await commit('c.dart', 'new file\n');

      final files = await source.rangeDiff(from: first, to: second);

      expect(files.single.path, 'c.dart');
    });

    test('resolves refs and checks ancestry', () async {
      final first = await commit('a.dart', 'one\n');
      final second = await commit('a.dart', 'two\n');

      expect(await source.resolve('HEAD'), second);
      expect(await source.isAncestor(first, second), isTrue);
      expect(await source.isAncestor(second, first), isFalse);
      expect(
        await source.isAncestor(
          '0123456789abcdef0123456789abcdef01234567',
          second,
        ),
        isFalse,
      );
    });

    test('reports git failures', () async {
      await commit('a.dart', 'one\n');
      await expectLater(
        source.resolve('no-such-branch'),
        throwsA(isA<GitException>()),
      );
    });
  });
}
