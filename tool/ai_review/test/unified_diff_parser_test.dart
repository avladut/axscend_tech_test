import 'package:ai_review/ai_review.dart';
import 'package:test/test.dart';

const _diff = r'''
diff --git a/lib/a.dart b/lib/a.dart
index 1111111..2222222 100644
--- a/lib/a.dart
+++ b/lib/a.dart
@@ -1,3 +1,4 @@
 line1
-old2
+new2
+new3
 line3
@@ -10,2 +11,2 @@ class X {
 ctx
-gone
+here
\ No newline at end of file
diff --git a/lib/new.dart b/lib/new.dart
new file mode 100644
index 0000000..3333333
--- /dev/null
+++ b/lib/new.dart
@@ -0,0 +1,2 @@
+a
+--b
diff --git a/old.md b/old.md
deleted file mode 100644
index 4444444..0000000
--- a/old.md
+++ /dev/null
@@ -1 +0,0 @@
-gone
diff --git a/img.png b/img.png
index 5555555..6666666 100644
Binary files a/img.png and b/img.png differ
diff --git a/lib/from.dart b/lib/to.dart
similarity index 90%
rename from lib/from.dart
rename to lib/to.dart
--- a/lib/from.dart
+++ b/lib/to.dart
@@ -1 +1 @@
-x
+y
''';

void main() {
  group(UnifiedDiffParser, () {
    final files = const UnifiedDiffParser().parse(_diff);
    FileDiff file(String path) => files.singleWhere((f) => f.path == path);

    test('finds one entry per file, with the new path', () {
      expect(files.map((f) => f.path), [
        'lib/a.dart',
        'lib/new.dart',
        'old.md',
        'img.png',
        'lib/to.dart',
      ]);
    });

    test('numbers added and context lines in the new file', () {
      expect(file('lib/a.dart').commentableLines, {1, 2, 3, 4, 11, 12});
      expect(file('lib/new.dart').commentableLines, {1, 2});
    });

    test('keeps a line starting with "--" inside a hunk as code', () {
      final added = file('lib/new.dart').lines
          .where((line) => line.kind == DiffLineKind.added);
      expect(added.map((line) => line.text), ['a', '--b']);
    });

    test('marks deleted and binary files', () {
      expect(file('old.md').isDeleted, isTrue);
      expect(file('img.png').isBinary, isTrue);
      expect(file('lib/a.dart').isDeleted, isFalse);
    });

    test('renders each line with its new line number', () {
      final rendered = file('lib/a.dart').render().split('\n');
      expect(rendered, contains('+    2 | new2'));
      expect(rendered, contains('-      | old2'));
      expect(rendered, contains('    11 | ctx'));
      expect(rendered.first, '@@ -1,3 +1,4 @@');
    });

    test('returns nothing for an empty diff', () {
      expect(const UnifiedDiffParser().parse(''), isEmpty);
    });
  });
}
