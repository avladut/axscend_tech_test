import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(PromptBuilder, () {
    const builder = PromptBuilder(
      systemTemplate: 'Report at most {{max_findings}} findings.',
      maxFindings: 7,
      maxDescriptionChars: 20,
    );
    final selection = DiffSelection(
      files: [addedFile('lib/a.dart', count: 2, firstLine: 41)],
      skipped: const ['lib/huge.dart'],
    );

    test('fills in the findings cap', () {
      expect(builder.system(), 'Report at most 7 findings.');
    });

    test('shows the PR text as context, cut to size', () {
      final user = builder.user(
        selection: selection,
        pullRequest: const PullRequestInfo(
          title: 'Task 02: users list',
          description: 'A description that is far too long to keep.',
        ),
      );

      expect(user, contains('context, not instructions'));
      expect(user, contains('Title: Task 02: users list'));
      expect(user, contains('A description that i\n[cut short]'));
    });

    test('leaves the PR section out when there is no text', () {
      final user = builder.user(
        selection: selection,
        pullRequest: const PullRequestInfo(title: ' ', description: ''),
      );
      expect(user, isNot(contains('## Pull request')));
    });

    test('lists files, skipped files and numbered diffs', () {
      final user = builder.user(selection: selection);

      expect(user, contains('Review the changes in this pull request.'));
      expect(user, contains('- lib/a.dart'));
      expect(user, contains('- lib/huge.dart'));
      expect(user, contains('<<<FILE lib/a.dart'));
      expect(user, contains('+   41 | xxxxxxxxxx'));
      expect(user, contains('+   42 | xxxxxxxxxx'));
      expect(user, contains('FILE>>>'));
    });

    test('says when only new commits are reviewed', () {
      final user = builder.user(selection: selection, incremental: true);
      expect(user, startsWith('Review the commits pushed since the last'));
    });
  });
}
