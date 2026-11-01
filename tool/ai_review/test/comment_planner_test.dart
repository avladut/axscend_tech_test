import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(CommentPlanner, () {
    const planner = CommentPlanner();
    final selection = DiffSelection(
      files: [
        addedFile('lib/first.dart', firstLine: 10),
        addedFile('lib/second.dart'),
      ],
    );

    PlannedComment planOne(Finding finding) => planner
        .plan(StructuredReview(summary: '', findings: [finding]), selection)
        .single;

    test('puts a finding on its line when the line is in the diff', () {
      final comment = planOne(finding(file: 'lib/second.dart', line: 2));
      expect(comment.placement, Placement.line);
      expect(comment.path, 'lib/second.dart');
      expect(comment.line, 2);
    });

    test('falls back to the file when the line is not in the diff', () {
      final comment = planOne(finding(file: 'lib/second.dart', line: 99));
      expect(comment.placement, Placement.file);
      expect(comment.path, 'lib/second.dart');
      expect(comment.line, isNull);
    });

    test('puts findings about unknown files on the first file', () {
      final unknown = planOne(finding(file: 'lib/nope.dart', line: 1));
      final noFile = planOne(finding());
      for (final comment in [unknown, noFile]) {
        expect(comment.placement, Placement.general);
        expect(comment.path, 'lib/first.dart');
      }
    });

    test('turns an unreadable answer into one thread', () {
      final comments = planner.plan(
        const UnstructuredReview('free text'),
        selection,
      );
      expect(comments.single.placement, Placement.general);
      expect(comments.single.finding.detail, 'free text');
    });

    test('plans nothing without reviewed files', () {
      expect(
        planner.plan(
          StructuredReview(summary: '', findings: [finding()]),
          DiffSelection(files: const []),
        ),
        isEmpty,
      );
    });
  });
}
