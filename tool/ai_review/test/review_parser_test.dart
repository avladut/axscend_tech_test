import 'dart:convert';

import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

void main() {
  group(ReviewParser, () {
    const parser = ReviewParser();

    StructuredReview structured(String answer) {
      final review = parser.parse(answer);
      expect(review, isA<StructuredReview>());
      return review as StructuredReview;
    }

    test('reads a valid answer', () {
      final review = structured(
        jsonEncode({
          'summary': ' Adds a cubit. ',
          'findings': [
            {
              'severity': 'major',
              'file': 'lib/a.dart',
              'line': 12,
              'title': 'Stream never closed',
              'detail': 'Leaks a subscription.',
              'suggestion': 'Cancel it in close().',
            },
          ],
        }),
      );

      expect(review.summary, 'Adds a cubit.');
      final finding = review.findings.single;
      expect(finding.severity, Severity.major);
      expect(finding.file, 'lib/a.dart');
      expect(finding.line, 12);
      expect(finding.title, 'Stream never closed');
      expect(finding.suggestion, 'Cancel it in close().');
      expect(review.droppedFindings, 0);
    });

    test('ignores a code fence and text around the JSON', () {
      final review = structured(
        'Here you go:\n```json\n{"summary": "ok", "findings": []}\n```\n',
      );
      expect(review.summary, 'ok');
      expect(review.findings, isEmpty);
    });

    test('keeps unreadable answers as unstructured text', () {
      final review = parser.parse('  I think it looks fine.  ');
      expect(review, isA<UnstructuredReview>());
      expect((review as UnstructuredReview).raw, 'I think it looks fine.');
    });

    test('keeps broken JSON as unstructured text', () {
      expect(parser.parse('{"summary": "cut off'), isA<UnstructuredReview>());
    });

    test('is lenient about fields', () {
      final review = structured(
        jsonEncode({
          'findings': [
            {
              'severity': 'CRITICAL',
              'line': ' 7 ',
              'detail': 'No title given, so one is made from the detail.',
              'extra': true,
            },
            {'severity': 'nit', 'title': 'Zero line', 'line': 0},
            {'severity': 'nit'},
            'not an object',
          ],
        }),
      );

      expect(review.summary, isEmpty);
      expect(review.findings, hasLength(2));
      final first = review.findings.first;
      expect(first.severity, Severity.minor);
      expect(first.line, 7);
      expect(first.title, startsWith('No title given'));
      expect(review.findings.last.line, isNull);
    });

    test('keeps the most severe findings when over the cap', () {
      final findings = [
        for (var i = 0; i < 6; i++) {'severity': 'nit', 'title': 'nit $i'},
        for (var i = 0; i < 5; i++) {'severity': 'major', 'title': 'major $i'},
        {'severity': 'blocker', 'title': 'the blocker'},
      ];
      final review = structured(
        jsonEncode({'summary': 's', 'findings': findings}),
      );

      expect(review.findings, hasLength(10));
      expect(review.droppedFindings, 2);
      expect(review.findings.first.title, 'the blocker');
      expect(review.findings[1].title, 'major 0');
      expect(review.findings.last.title, 'nit 3');
    });
  });

  group('ReviewParser.merge', () {
    const parser = ReviewParser(maxFindings: 2);
    Finding finding(Severity severity, String title) =>
        Finding(severity: severity, title: title, detail: 'd');

    test('returns a single part as it is', () {
      const only = UnstructuredReview('not json');

      expect(parser.merge([only]), same(only));
    });

    test('joins the summaries and sorts and caps all findings', () {
      final merged = parser.merge([
        StructuredReview(
          summary: 'First half.',
          findings: [finding(Severity.minor, 'a')],
          droppedFindings: 1,
        ),
        StructuredReview(
          summary: 'Second half.',
          findings: [finding(Severity.nit, 'b'), finding(Severity.major, 'c')],
        ),
      ]);

      expect(merged, isA<StructuredReview>());
      final review = merged as StructuredReview;
      expect(
        review.summary,
        '**Part 1:** First half.\n\n**Part 2:** Second half.',
      );
      expect(review.findings.map((f) => f.title), ['c', 'a']);
      // 1 dropped by part 1, plus the nit that didn't make the cap.
      expect(review.droppedFindings, 2);
    });

    test("turns a part that wasn't JSON into a finding", () {
      final review = parser.merge([
        const StructuredReview(summary: '', findings: []),
        const UnstructuredReview('garbled'),
      ]) as StructuredReview;

      expect(review.findings.single.title, contains("Part 2's answer"));
      expect(review.findings.single.detail, 'garbled');
      expect(review.summary, contains("wasn't valid JSON"));
    });
  });
}
