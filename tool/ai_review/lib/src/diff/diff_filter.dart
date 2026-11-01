import 'package:ai_review/src/diff/file_diff.dart';

/// The files that will be sent to the model, and what didn't fit.
class DiffSelection {
  const new({required this.files, this.skipped = const []});

  final List<FileDiff> files;

  /// Reviewable files left out because of the size cap.
  final List<String> skipped;

  bool get isEmpty => files.isEmpty;

  FileDiff? fileAt(String path) {
    for (final file in files) {
      if (file.path == path) return file;
    }
    return null;
  }
}

/// Decides which changed files are worth reviewing, and caps the total size.
class DiffFilter {
  const new({this.maxChars = 60000});

  /// Rough budget for the diff in the prompt. About 15–20k tokens, which
  /// keeps prompt processing well inside the server tunnel's time limit.
  final int maxChars;

  /// Below this, a truncated file isn't worth sending.
  static const _minUsefulChars = 1000;

  static const _reviewedExtensions = ['.dart', '.yaml', '.yml', '.md'];

  static final _platformFolder = RegExp(
    '^apps/[^/]+/(android|ios|web|macos|linux|windows)/',
  );

  bool isReviewable(FileDiff file) {
    if (file.isBinary || file.isDeleted) return false;
    final path = file.path;
    final name = path.split('/').last;
    if (!_reviewedExtensions.any(name.endsWith)) return false;
    if (name.endsWith('.g.dart') || name.endsWith('.freezed.dart')) {
      return false;
    }
    // Output of `flutter gen-l10n`.
    if (name.startsWith('app_localizations') && name.endsWith('.dart')) {
      return false;
    }
    return !_platformFolder.hasMatch(path);
  }

  /// Biggest changes first, until the budget runs out. A file that alone is
  /// bigger than what's left is cut to fit, as long as enough room remains.
  DiffSelection select(List<FileDiff> files) {
    final reviewable = files.where(isReviewable).toList()
      ..sort((a, b) => b.renderedLength.compareTo(a.renderedLength));

    final selected = <FileDiff>[];
    final skipped = <String>[];
    var used = 0;
    for (final file in reviewable) {
      final size = file.renderedLength;
      final left = maxChars - used;
      if (size <= left) {
        selected.add(file);
        used += size;
      } else if (left >= _minUsefulChars) {
        final cut = file.truncatedTo(left);
        selected.add(cut);
        used += cut.renderedLength;
      } else {
        skipped.add(file.path);
      }
    }
    return DiffSelection(files: selected, skipped: skipped);
  }
}
