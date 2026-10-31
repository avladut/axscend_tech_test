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

      final selection = const DiffFilter(maxChars: 1000)
          .select([small, big, medium]);

      expect(selection.files.map((f) => f.path), ['big.dart', 'medium.dart']);
      expect(selection.skipped, ['small.dart']);
    });

    test('cuts a file that alone is over the budget', () {
      final huge = sized('huge.dart', 60);
      final other = sized('other.dart', 5);

      final selection = const DiffFilter(maxChars: 1500).select([huge, other]);

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

    test('is empty when nothing is reviewable', () {
      expect(
        const DiffFilter().select([addedFile('pubspec.lock')]).isEmpty,
        isTrue,
      );
    });
  });
}
