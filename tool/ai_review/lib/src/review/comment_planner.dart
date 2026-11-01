import 'package:ai_review/src/diff/diff_filter.dart';
import 'package:ai_review/src/review/finding.dart';

/// Where a finding's thread goes on GitHub.
enum Placement {
  /// On the exact line: the line is part of the diff.
  line,

  /// On the file: the file is in the diff, the line isn't.
  file,

  /// Not tied to a reviewed file. Attached to the first reviewed file so it
  /// is still a thread that has to be resolved.
  general,
}

class PlannedComment {
  const new({
    required this.finding,
    required this.path,
    required this.placement,
    this.line,
  });

  final Finding finding;
  final String path;
  final Placement placement;

  /// Set only for [Placement.line].
  final int? line;
}

/// Turns findings into threads GitHub will accept. Every finding becomes a
/// thread, because each one needs Alex's decision before the PR can merge.
class CommentPlanner {
  const new();

  List<PlannedComment> plan(ParsedReview review, DiffSelection selection) {
    if (selection.isEmpty) return const [];
    final fallbackPath = selection.files.first.path;

    final findings = switch (review) {
      StructuredReview(:final findings) => findings,
      // Unreadable answer: still one thread, so it gets a human decision.
      UnstructuredReview(:final raw) => [
        Finding(
          severity: Severity.minor,
          title: "The model's answer couldn't be read as JSON",
          detail: raw,
        ),
      ],
    };

    return [
      for (final finding in findings) _place(finding, selection, fallbackPath),
    ];
  }

  PlannedComment _place(
    Finding finding,
    DiffSelection selection,
    String fallbackPath,
  ) {
    final file = finding.file == null ? null : selection.fileAt(finding.file!);
    if (file == null) {
      return PlannedComment(
        finding: finding,
        path: fallbackPath,
        placement: Placement.general,
      );
    }
    final line = finding.line;
    if (line != null && file.commentableLines.contains(line)) {
      return PlannedComment(
        finding: finding,
        path: file.path,
        placement: Placement.line,
        line: line,
      );
    }
    return PlannedComment(
      finding: finding,
      path: file.path,
      placement: Placement.file,
    );
  }
}
