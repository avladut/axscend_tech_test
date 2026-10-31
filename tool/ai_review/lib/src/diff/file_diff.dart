/// What a line in a unified diff is.
enum DiffLineKind { hunk, added, removed, context, note }

/// One line of a file's diff. [newLine] is its line number in the new
/// version of the file, or null when the line doesn't exist there.
class DiffLine {
  const new(this.kind, this.text, {this.newLine});

  final DiffLineKind kind;
  final String text;
  final int? newLine;
}

/// The changes to one file between two commits.
class FileDiff {
  const new({
    required this.path,
    required this.lines,
    this.isBinary = false,
    this.isDeleted = false,
    this.isTruncated = false,
  });

  final String path;
  final List<DiffLine> lines;
  final bool isBinary;
  final bool isDeleted;
  final bool isTruncated;

  /// Line numbers (new version) that GitHub accepts a review comment on:
  /// every added or context line inside a hunk.
  Set<int> get commentableLines => {
    for (final line in lines)
      if (line.newLine != null) line.newLine!,
  };

  /// The diff as sent to the model, with the new line number in front of
  /// every line so the model never has to count lines itself.
  String render() {
    final buffer = StringBuffer();
    for (final line in lines) {
      buffer.writeln(_renderLine(line));
    }
    return buffer.toString();
  }

  /// Length of [render], which is what the size cap is measured in.
  int get renderedLength => render().length;

  /// A copy that keeps only the leading lines that fit in [maxChars].
  FileDiff truncatedTo(int maxChars) {
    final kept = <DiffLine>[];
    var used = 0;
    for (final line in lines) {
      final length = _renderLine(line).length + 1;
      if (used + length > maxChars) break;
      kept.add(line);
      used += length;
    }
    return FileDiff(
      path: path,
      lines: kept,
      isBinary: isBinary,
      isDeleted: isDeleted,
      isTruncated: true,
    );
  }

  static String _renderLine(DiffLine line) {
    final number = line.newLine?.toString().padLeft(5) ?? '     ';
    return switch (line.kind) {
      DiffLineKind.hunk || DiffLineKind.note => line.text,
      DiffLineKind.added => '+$number | ${line.text}',
      DiffLineKind.removed => '-$number | ${line.text}',
      DiffLineKind.context => ' $number | ${line.text}',
    };
  }
}
