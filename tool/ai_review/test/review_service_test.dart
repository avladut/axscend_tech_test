import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(ReviewService, () {
    late FakeModel model;
    late RecordingPublisher publisher;
    late FakeDiffSource diffSource;
    late List<String> log;

    ReviewService service({
      String? lastSha,
      List<FileDiff>? files,
      Set<String> ancestors = const {},
      FakeModel? withModel,
    }) {
      model = withModel ?? FakeModel();
      publisher = RecordingPublisher(lastSha: lastSha);
      diffSource = FakeDiffSource(
        files: files ?? [addedFile('lib/a.dart')],
        ancestors: ancestors,
      );
      log = [];
      return ReviewService(
        diffSource: diffSource,
        model: model,
        publisher: publisher,
        prompts: const PromptBuilder(systemTemplate: 'system'),
        log: log.add,
      );
    }

    test('reviews the whole PR the first time', () async {
      final outcome = await service().run(base: 'main', head: 'HEAD');

      expect(outcome, ReviewOutcome.published);
      expect(diffSource.calls, ['pr main...$shaB']);
      expect(model.lastSchema, ReviewParser.schema);
      expect(model.lastUser, contains('Review the changes in this pull'));
      final report = publisher.report!;
      expect(report.headSha, shaB);
      expect(report.sinceSha, isNull);
      expect(report.model, 'fake-model');
      expect(report.promptTokens, 100);
    });

    test('reviews only new commits after an earlier review', () async {
      final outcome = await service(
        lastSha: shaA,
        ancestors: {'$shaA..$shaB'},
      ).run(base: 'main', head: 'HEAD');

      expect(outcome, ReviewOutcome.published);
      expect(diffSource.calls, ['range $shaA..$shaB']);
      expect(model.lastUser, contains('pushed since the last review'));
      expect(publisher.report!.sinceSha, shaA);
    });

    test('reviews the whole PR again after a force-push', () async {
      await service(lastSha: shaA).run(base: 'main', head: 'HEAD');

      expect(diffSource.calls, ['pr main...$shaB']);
      expect(publisher.report!.sinceSha, isNull);
      expect(log.join(), contains('force-push'));
    });

    test('does nothing when the commit was already reviewed', () async {
      final outcome = await service(lastSha: shaB)
          .run(base: 'main', head: 'HEAD');

      expect(outcome, ReviewOutcome.alreadyReviewed);
      expect(model.calls, 0);
      expect(publisher.report, isNull);
    });

    test('ignores earlier reviews when not incremental', () async {
      await service(lastSha: shaB)
          .run(base: 'main', head: 'HEAD', incremental: false);

      expect(publisher.historyReads, 0);
      expect(publisher.report, isNotNull);
    });

    test('skips the model when nothing reviewable changed', () async {
      final outcome = await service(files: [addedFile('pubspec.lock')])
          .run(base: 'main', head: 'HEAD');

      expect(outcome, ReviewOutcome.nothingToReview);
      expect(model.calls, 0);
      expect(publisher.report, isNull);
    });

    test('posts "unavailable" when the model fails', () async {
      final outcome = await service(
        withModel: FakeModel(error: const ReviewModelException('timed out')),
      ).run(base: 'main', head: 'HEAD');

      expect(outcome, ReviewOutcome.modelUnavailable);
      expect(publisher.unavailableReason, 'timed out');
      expect(publisher.report, isNull);
    });

    test('turns findings into planned threads', () async {
      await service(
        withModel: FakeModel(
          answer:
              '{"summary": "s", "findings": [{"severity": "major", '
              '"file": "lib/a.dart", "line": 2, "title": "t", "detail": "d"}]}',
        ),
      ).run(base: 'main', head: 'HEAD');

      final comment = publisher.comments!.single;
      expect(comment.placement, Placement.line);
      expect(comment.line, 2);
    });

    test('passes the PR text to the prompt', () async {
      await service().run(
        base: 'main',
        head: 'HEAD',
        pullRequest: const PullRequestInfo(title: 'Task 02'),
      );
      expect(model.lastUser, contains('Title: Task 02'));
    });
  });
}
