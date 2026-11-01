import 'package:ai_review/src/diff/file_diff.dart';

/// The files that will be sent to the model, in parts that each fit one
/// model call, and what didn't fit at all.
class DiffSelection {
  /// Everything in one part, as for a small pull request.
  new({required List<FileDiff> files, this.skipped = const []})
    : batches = files.isEmpty ? const [] : [files];

  const new batched({required this.batches, this.skipped = const []});

  /// One model call each.
  final List<List<FileDiff>> batches;

  /// Reviewable files left out because of the size cap.
  final List<String> skipped;

  /// Every file that is sent, across all parts.
  List<FileDiff> get files => [for (final batch in batches) ...batch];

  bool get isEmpty => batches.every((batch) => batch.isEmpty);

  FileDiff? fileAt(String path) {
    for (final file in files) {
      if (file.path == path) return file;
    }
    return null;
  }
}

/// Decides which changed files are worth reviewing, and packs them into
/// parts of at most [maxChars] each.
class DiffFilter {
  const new({this.maxChars = 60000, this.maxBatches = 4});

  /// Rough budget for the diff in one model call. About 15–20k tokens, which
  /// keeps prompt processing well inside the server tunnel's time limit.
  final int maxChars;

  /// How many model calls one review may make.
  final int maxBatches;

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

  /// Lower goes first: app code, then config, then tests, then docs. The
  /// most useful review is of the code that ships.
  static int priorityOf(String path) {
    final name = path.split('/').last;
    if (name.endsWith('.md')) return 3;
    if (name.endsWith('_test.dart') ||
        path.startsWith('test/') ||
        path.contains('/test/')) {
      return 2;
    }
    if (name.endsWith('.dart')) return 0;
    return 1;
  }

  /// Most important first, biggest first within the same kind (then by
  /// path). Each file goes
  /// in the first part it fits in, and a new part starts when none has room.
  /// Once [maxBatches] parts are full, a file is cut to fit the roomiest one
  /// if enough room remains, and left out otherwise.
  DiffSelection select(List<FileDiff> files) {
    final reviewable = files.where(isReviewable).toList()
      ..sort((a, b) {
        final byKind = priorityOf(a.path).compareTo(priorityOf(b.path));
        if (byKind != 0) return byKind;
        final bySize = b.renderedLength.compareTo(a.renderedLength);
        // Ties by path, so the same PR always splits the same way.
        return bySize != 0 ? bySize : a.path.compareTo(b.path);
      });

    final batches = <List<FileDiff>>[];
    final used = <int>[];
    final skipped = <String>[];
    for (final file in reviewable) {
      final size = file.renderedLength;
      final fits = [
        for (var i = 0; i < batches.length; i++)
          if (size <= maxChars - used[i]) i,
      ].firstOrNull;
      if (fits != null) {
        batches[fits].add(file);
        used[fits] += size;
        continue;
      }
      if (batches.length < maxBatches) {
        final part = size <= maxChars ? file : file.truncatedTo(maxChars);
        batches.add([part]);
        used.add(part.renderedLength);
        continue;
      }
      var roomiest = 0;
      for (var i = 1; i < batches.length; i++) {
        if (used[i] < used[roomiest]) roomiest = i;
      }
      final left = maxChars - used[roomiest];
      if (left >= _minUsefulChars) {
        final cut = file.truncatedTo(left);
        batches[roomiest].add(cut);
        used[roomiest] += cut.renderedLength;
      } else {
        skipped.add(file.path);
      }
    }
    return DiffSelection.batched(batches: batches, skipped: skipped);
  }
}
