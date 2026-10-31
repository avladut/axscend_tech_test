import 'package:ai_review/src/diff/file_diff.dart';

/// Parses `git diff` output (unified format) into one [FileDiff] per file.
class UnifiedDiffParser {
  const new();

  static final _hunkHeader = RegExp(r'^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@');

  List<FileDiff> parse(String diff) {
    final files = <FileDiff>[];
    _FileBuilder? current;

    for (final raw in diff.split('\n')) {
      if (raw.startsWith('diff --git ')) {
        if (current != null) files.add(current.build());
        current = _FileBuilder(_pathFromHeader(raw));
        continue;
      }
      final file = current;
      if (file == null) continue;

      if (file.inHunk) {
        if (raw.startsWith('@@')) {
          file.startHunk(raw);
        } else if (raw.startsWith('+')) {
          file.add(DiffLineKind.added, raw.substring(1));
        } else if (raw.startsWith('-')) {
          file.add(DiffLineKind.removed, raw.substring(1));
        } else if (raw.startsWith(' ')) {
          file.add(DiffLineKind.context, raw.substring(1));
        } else if (raw.startsWith(r'\')) {
          file.lines.add(DiffLine(DiffLineKind.note, raw));
        }
        // Anything else (e.g. the empty last line of the output) is ignored.
        continue;
      }

      if (raw.startsWith('@@')) {
        file.startHunk(raw);
      } else if (raw.startsWith('+++ ')) {
        final target = raw.substring(4);
        if (target != '/dev/null') file.path = _stripPrefix(target, 'b/');
      } else if (raw.startsWith('deleted file mode')) {
        file.isDeleted = true;
      } else if (raw.startsWith('Binary files ') || raw == 'GIT binary patch') {
        file.isBinary = true;
      }
    }
    if (current != null) files.add(current.build());
    return files;
  }

  /// `diff --git a/x b/x`: the path after the last ` b/`. Good enough for
  /// the header; the `+++` line, when present, overrides it.
  static String _pathFromHeader(String header) {
    final index = header.lastIndexOf(' b/');
    return index == -1 ? header : header.substring(index + 3);
  }

  static String _stripPrefix(String value, String prefix) =>
      value.startsWith(prefix) ? value.substring(prefix.length) : value;

  static int? newStartOf(String hunkHeader) {
    final match = _hunkHeader.firstMatch(hunkHeader);
    return match == null ? null : int.parse(match.group(1)!);
  }
}

class _FileBuilder {
  new(this.path);

  String path;
  bool isBinary = false;
  bool isDeleted = false;
  bool inHunk = false;
  int _nextNewLine = 0;
  final List<DiffLine> lines = [];

  void startHunk(String header) {
    inHunk = true;
    _nextNewLine = UnifiedDiffParser.newStartOf(header) ?? 0;
    lines.add(DiffLine(DiffLineKind.hunk, header));
  }

  void add(DiffLineKind kind, String text) {
    if (kind == DiffLineKind.removed) {
      lines.add(DiffLine(kind, text));
    } else {
      lines.add(DiffLine(kind, text, newLine: _nextNewLine++));
    }
  }

  FileDiff build() => FileDiff(
    path: path,
    lines: List.unmodifiable(lines),
    isBinary: isBinary,
    isDeleted: isDeleted,
  );
}
