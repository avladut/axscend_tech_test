import 'dart:convert';

import 'package:ai_review/ai_review.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

const _diff = '''
diff --git a/lib/a.dart b/lib/a.dart
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1 +1,2 @@
 void main() {}
+void unused() {}
''';

void main() {
  group('runCli', () {
    late StringBuffer out;
    late StringBuffer err;

    setUp(() {
      out = StringBuffer();
      err = StringBuffer();
    });

    final modelEnv = {
      'AI_REVIEW_BASE_URL': 'https://models.example/v1',
      'AI_REVIEW_API_KEY': 'test-key',
    };

    FakeGitRunner git() => FakeGitRunner({
      'rev-parse --verify HEAD^{commit}': const GitResult(0, '$shaB\n', ''),
      'diff ': const GitResult(0, _diff, ''),
    });

    test('skips with a notice on GitHub when not configured yet', () async {
      final code = await runCli(
        const [],
        environment: const {},
        out: out,
        err: err,
      );

      expect(code, 0);
      expect(out.toString(), startsWith('::notice::'));
    });

    test('says "not configured" on the PR when it can', () async {
      final posted = <String>[];
      final client = MockClient((request) async {
        posted.add(request.body);
        return http.Response('{}', 201);
      });

      final code = await runCli(
        const [],
        environment: {
          'GITHUB_TOKEN': 'gh-token',
          'GITHUB_REPOSITORY': 'avladut/axscend_tech_test',
          'PR_NUMBER': '7',
          'HEAD_SHA': shaB,
        },
        out: out,
        err: err,
        httpClient: client,
      );

      expect(code, 0);
      final body = (jsonDecode(posted.single) as Map)['body'] as String;
      expect(body, contains('### 🤖 AI review: not configured'));
      expect(body, contains('AI_REVIEW_API_KEY'));
    });

    test('fails locally when not configured', () async {
      final code = await runCli(
        const ['--print'],
        environment: const {},
        out: out,
        err: err,
      );

      expect(code, 64);
      expect(err.toString(), contains('AI_REVIEW_BASE_URL'));
    });

    test('rejects a bad number', () async {
      final code = await runCli(
        const ['--print', '--max-findings', 'lots'],
        environment: modelEnv,
        out: out,
        err: err,
      );
      expect(code, 64);
    });

    test('needs the PR details to post on GitHub', () async {
      final code = await runCli(
        const [],
        environment: modelEnv,
        out: out,
        err: err,
        git: git(),
      );

      expect(code, 64);
      expect(err.toString(), contains('PR_NUMBER'));
    });

    test('prints a review end to end with --print', () async {
      final answer = jsonEncode({
        'summary': 'Adds an unused function.',
        'findings': [
          {
            'severity': 'minor',
            'file': 'lib/a.dart',
            'line': 2,
            'title': 'Unused function',
            'detail': 'Nothing calls it.',
          },
        ],
      });
      final client = MockClient.streaming(
        (request, body) async => sseResponse([answer]),
      );

      final code = await runCli(
        const ['--print', '--base', 'main'],
        environment: modelEnv,
        out: out,
        err: err,
        git: git(),
        httpClient: client,
      );

      expect(code, 0, reason: err.toString());
      final printed = out.toString();
      expect(printed, contains('### 🤖 AI review (advisory)'));
      expect(printed, contains('Adds an unused function.'));
      expect(printed, contains('──── lib/a.dart:2 ────'));
      expect(printed, contains('🟡 Minor: Unused function'));
    });

    test('reports the model as unavailable and still succeeds', () async {
      final client = MockClient.streaming(
        (request, body) async => throw Exception('down'),
      );

      final code = await runCli(
        const ['--print', '--base', 'main'],
        environment: modelEnv,
        out: out,
        err: err,
        git: git(),
        httpClient: client,
      );

      expect(code, 0);
      expect(out.toString(), contains('AI review unavailable'));
    });
  });
}
