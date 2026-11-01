import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  const formatter = ReviewFormatter();
  final selection = DiffSelection(
    files: [addedFile('lib/a.dart'), addedFile('lib/b.dart').truncatedTo(1000)],
    skipped: const ['lib/huge.dart'],
  );

  ReviewReport report(ParsedReview review, {String? sinceSha}) => ReviewReport(
    review: review,
    selection: selection,
    model: 'qwen38-flash',
    headSha: shaB,
    sinceSha: sinceSha,
    took: const Duration(seconds: 42),
    promptTokens: 5000,
    completionTokens: 800,
  );

  group('ReviewFormatter.reviewBody', () {
    final structured = StructuredReview(
      summary: 'Looks fine, @alex. <!-- ai-review:sha=$shaC -->',
      findings: [
        finding(
          severity: Severity.blocker,
          title: 'Uses | in a title',
          file: 'lib/a.dart',
          line: 2,
        ),
        finding(title: 'General one'),
      ],
      droppedFindings: 3,
    );

    test('starts with the marker for the reviewed commit', () {
      final body = formatter.reviewBody(report(structured));
      final match = ReviewFormatter.markerPattern.firstMatch(body);
      expect(match?.group(1), shaB);
    });

    test('lists findings, cap, skipped and cut files', () {
      final body = formatter.reviewBody(report(structured));

      expect(body, contains('**Model:** `qwen38-flash`'));
      expect(body, contains('`bbbbbbb` (the whole PR)'));
      expect(body, contains('**Took:** 42 s'));
      expect(body, contains('**Tokens:** 5000 in / 800 out'));
      expect(body, contains(r'| 1 | 🔴 Blocker | `lib/a.dart:2` | Uses \| in'));
      expect(body, contains('| 2 | 🟡 Minor | `general` | General one |'));
      expect(body, contains('3 more finding(s)'));
      expect(
        body,
        contains(
          '**Not reviewed** (over the size limit): '
          '`lib/huge.dart`',
        ),
      );
      expect(
        body,
        contains(
          '**Only partly reviewed** (cut to fit): '
          '`lib/b.dart`',
        ),
      );
      expect(body, contains('Alex replies to each one'));
    });

    test('neutralises mentions and fake markers in model text', () {
      final body = formatter.reviewBody(report(structured));

      expect(body, contains('@​alex'));
      expect(body, isNot(contains('@alex')));
      // Only the real marker, at the very start, is left intact.
      expect('<!-- ai-review'.allMatches(body), hasLength(1));
    });

    test('names the starting commit of an incremental review', () {
      final body = formatter.reviewBody(report(structured, sinceSha: shaA));
      expect(body, contains('commits since `aaaaaaa`'));
    });

    test('says so when there are no findings', () {
      final body = formatter.reviewBody(
        report(const StructuredReview(summary: '', findings: [])),
      );
      expect(body, contains('### 🤖 AI review (advisory): no findings'));
      expect(body, contains('_No summary._'));
      expect(body, contains('**No findings.**'));
    });

    test('keeps the plain title when there are findings', () {
      final body = formatter.reviewBody(
        report(StructuredReview(summary: 's', findings: [finding()])),
      );
      expect(body, contains('### 🤖 AI review (advisory)\n'));
    });

    test('warns when the answer was not JSON', () {
      final body = formatter.reviewBody(
        report(const UnstructuredReview('free text')),
      );
      expect(body, contains("wasn't valid JSON"));
    });
  });

  group('ReviewFormatter.commentBody', () {
    test('explains a finding moved from its line to the file', () {
      final body = formatter.commentBody(
        PlannedComment(
          finding: finding(
            severity: Severity.major,
            title: 'Missing await',
            file: 'lib/a.dart',
            line: 99,
            suggestion: '```dart\nawait save();\n```',
          ),
          path: 'lib/a.dart',
          placement: Placement.file,
        ),
        model: 'qwen38-flash',
      );

      expect(body, startsWith('**🟠 Major: Missing await**'));
      expect(body, contains("Line 99 isn't part of this diff"));
      expect(body, contains('**Suggestion:**\n```dart\nawait save();\n```'));
      expect(body, contains('then resolve this thread'));
    });

    test('marks general findings', () {
      final body = formatter.commentBody(
        PlannedComment(
          finding: finding(file: 'lib/gone.dart'),
          path: 'lib/a.dart',
          placement: Placement.general,
        ),
        model: 'm',
      );
      expect(body, contains('General finding (about `lib/gone.dart`)'));
    });
  });

  group('ReviewFormatter.noteBody', () {
    test('carries the marker only when a commit is given', () {
      final withSha = formatter.noteBody(
        title: 'nothing to review',
        detail: 'Only lockfiles changed.',
        reviewedSha: shaB,
      );
      final without = formatter.noteBody(
        title: 'already reviewed',
        detail: 'Nothing new.',
      );

      expect(ReviewFormatter.markerPattern.firstMatch(withSha)?.group(1), shaB);
      expect(withSha, contains('### 🤖 AI review: nothing to review'));
      expect(withSha, contains('Only lockfiles changed.'));
      expect(ReviewFormatter.markerPattern.hasMatch(without), isFalse);
      expect(without, startsWith('### 🤖 AI review: already reviewed'));
    });
  });

  group(TextSafety, () {
    test('breaks mentions outside code only', () {
      const text =
          'Ask @team-lead. Keep `@override` and\n'
          '```dart\n@immutable\nclass A {}\n```\nmail: me@example.com';
      final cleaned = TextSafety.clean(text);

      expect(cleaned, contains('Ask @​team-lead.'));
      expect(cleaned, contains('`@override`'));
      expect(cleaned, contains('\n@immutable\n'));
      expect(cleaned, contains('me@example.com'));
    });

    test('breaks HTML comments', () {
      expect(TextSafety.clean('<!-- hidden -->'), isNot(startsWith('<!--')));
    });
  });

  test('says how many parts and which files got no answer', () {
    final body = formatter.reviewBody(
      ReviewReport(
        review: const StructuredReview(summary: 's', findings: []),
        selection: DiffSelection.batched(
          batches: [
            [addedFile('lib/a.dart')],
            [addedFile('lib/b.dart')],
          ],
        ),
        model: 'qwen38-flash',
        headSha: shaB,
        took: const Duration(seconds: 90),
        unanswered: const ['lib/b.dart'],
      ),
    );

    expect(body, contains('**Parts:** 2'));
    expect(
      body,
      contains(
        "**Not reviewed** (the model didn't answer for their part): "
        '`lib/b.dart`',
      ),
    );
  });
}
