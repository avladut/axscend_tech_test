import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group('DiffFilter.isReviewable', () {
    const filter = DiffFilter();

    for (final path in [
      'apps/axscend_tech_test/lib/main.dart',
      'packages/domain/lib/domain.dart',
      'pubspec.yaml',
      '.github/workflows/ci.yml',
      'README.md',
      'packages/app_ui/lib/web/thing.dart',
    ]) {
      test('reviews $path', () {
        expect(filter.isReviewable(addedFile(path)), isTrue);
      });
    }

    for (final path in [
      'pubspec.lock',
      'lib/model.g.dart',
      'lib/model.freezed.dart',
      'apps/axscend_tech_test/lib/l10n/app_localizations_en.dart',
      'apps/axscend_tech_test/ios/Runner/Config.yaml',
      'apps/axscend_tech_test/web/manifest.yaml',
      'apps/axscend_tech_test/android/app/src/main/AndroidManifest.xml',
      'assets/logo.png',
    ]) {
      test('skips $path', () {
        expect(filter.isReviewable(addedFile(path)), isFalse);
      });
    }

    test('skips deleted and binary files', () {
      const deleted = FileDiff(path: 'a.dart', lines: [], isDeleted: true);
      const binary = FileDiff(path: 'b.dart', lines: [], isBinary: true);
      expect(filter.isReviewable(deleted), isFalse);
      expect(filter.isReviewable(binary), isFalse);
    });
  });

  group('DiffFilter.select', () {
    // A file renders to 15 characters of hunk header plus 51 per added line.
    FileDiff sized(String path, int lines) =>
        addedFile(path, count: lines, width: 41);

    test('takes the biggest files first and skips what no longer fits', () {
      final small = sized('small.dart', 2); // 117
      final big = sized('big.dart', 10); // 525
      final medium = sized('medium.dart', 8); // 423

      final selection = const DiffFilter(
        maxChars: 1000,
        maxBatches: 1,
      ).select([small, big, medium]);

      expect(selection.files.map((f) => f.path), ['big.dart', 'medium.dart']);
      expect(selection.skipped, ['small.dart']);
    });

    test('cuts a file that alone is over the budget', () {
      final huge = sized('huge.dart', 60);
      final other = sized('other.dart', 5);

      final selection = const DiffFilter(
        maxChars: 1500,
        maxBatches: 1,
      ).select([huge, other]);

      expect(selection.files.single.path, 'huge.dart');
      expect(selection.files.single.isTruncated, isTrue);
      expect(selection.files.single.renderedLength, lessThanOrEqualTo(1500));
      expect(selection.skipped, ['other.dart']);
    });

    test('leaves out files that are not reviewable without listing them', () {
      final selection = const DiffFilter().select([
        addedFile('pubspec.lock'),
        addedFile('lib/a.dart'),
      ]);

      expect(selection.files.map((f) => f.path), ['lib/a.dart']);
      expect(selection.skipped, isEmpty);
    });

    test('packs files into parts that each fit the budget', () {
      final big = sized('lib/big.dart', 10); // 525
      final medium = sized('lib/medium.dart', 8); // 423
      final other = sized('lib/other.dart', 7); // 372
      final small = sized('lib/small.dart', 2); // 117

      final selection = const DiffFilter(maxChars: 1000)
          .select([small, other, big, medium]);

      expect(selection.batches.map((part) => part.map((file) => file.path)), [
        ['lib/big.dart', 'lib/medium.dart'],
        ['lib/other.dart', 'lib/small.dart'],
      ]);
      expect(selection.skipped, isEmpty);
      for (final part in selection.batches) {
        expect(
          part.fold(0, (sum, file) => sum + file.renderedLength),
          lessThanOrEqualTo(1000),
        );
      }
    });

    test('puts app code first, then config, tests and docs', () {
      final selection = const DiffFilter().select([
        sized('README.md', 20),
        sized('packages/x/test/a_test.dart', 20),
        sized('pubspec.yaml', 2),
        sized('lib/a.dart', 1),
      ]);

      expect(selection.files.map((file) => file.path), [
        'lib/a.dart',
        'pubspec.yaml',
        'packages/x/test/a_test.dart',
        'README.md',
      ]);
    });

    test('leaves out the least important files once every part is full', () {
      final selection = const DiffFilter(maxChars: 600, maxBatches: 2).select([
        sized('docs/guide.md', 10),
        sized('lib/a.dart', 10),
        sized('lib/b.dart', 10),
      ]);

      expect(selection.batches, hasLength(2));
      expect(selection.files.map((file) => file.path), [
        'lib/a.dart',
        'lib/b.dart',
      ]);
      expect(selection.skipped, ['docs/guide.md']);
    });

    test('splits the same files the same way every time', () {
      final files = [
        sized('lib/c.dart', 8),
        sized('lib/a.dart', 8),
        sized('lib/b.dart', 8),
      ];
      const filter = DiffFilter(maxChars: 900);

      final once = filter.select(files).files.map((file) => file.path);
      final again = filter
          .select(files.reversed.toList())
          .files
          .map((file) => file.path);

      expect(once, ['lib/a.dart', 'lib/b.dart', 'lib/c.dart']);
      expect(again, once);
    });

    test('priorityOf ranks app code, config, tests and docs', () {
      expect(DiffFilter.priorityOf('apps/app/lib/main.dart'), 0);
      expect(DiffFilter.priorityOf('.github/workflows/ci.yml'), 1);
      expect(DiffFilter.priorityOf('test/a_test.dart'), 2);
      expect(DiffFilter.priorityOf('tool/x/test/support/fakes.dart'), 2);
      expect(DiffFilter.priorityOf('docs/adr/0001.md'), 3);
    });

    test('is empty when nothing is reviewable', () {
      expect(
        const DiffFilter().select([addedFile('pubspec.lock')]).isEmpty,
        isTrue,
      );
    });
  });
}
