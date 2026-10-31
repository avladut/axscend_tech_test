import 'package:ai_review/src/diff/diff_filter.dart';
import 'package:ai_review/src/review/comment_planner.dart';
import 'package:ai_review/src/review/finding.dart';
import 'package:ai_review/src/review/text_safety.dart';

/// Everything known about one finished review.
class ReviewReport {
  const new({
    required this.review,
    required this.selection,
    required this.model,
    required this.headSha,
    required this.took,
    this.sinceSha,
    this.promptTokens,
    this.completionTokens,
  });

  final ParsedReview review;
  final DiffSelection selection;
  final String model;
  final String headSha;
  final Duration took;

  /// Set when only the commits after this one were reviewed.
  final String? sinceSha;
  final int? promptTokens;
  final int? completionTokens;
}

/// Writes the review's Markdown. All model text goes through [TextSafety].
class ReviewFormatter {
  const new();

  /// Hidden marker in the review body: the commit this review covered.
  static final markerPattern = RegExp('^<!-- ai-review:sha=([0-9a-f]{40}) -->');

  static String marker(String sha) => '<!-- ai-review:sha=$sha -->';

  static const _decisionNote =
      'Each finding is its own thread. **Alex replies to each one (accept, '
      'or ask for a change) and resolves it**; `main` only accepts the merge '
      'once every thread is resolved. This bot only comments: it never '
      'approves, blocks or merges.';

  String reviewBody(ReviewReport report) {
    final out = StringBuffer()
      ..writeln(marker(report.headSha))
      ..writeln('### 🤖 AI review (advisory)')
      ..writeln()
      ..writeln(_metaLine(report))
      ..writeln();

    switch (report.review) {
      case StructuredReview(
        :final summary,
        :final findings,
        droppedFindings: final dropped,
      ):
        final text = summary.isEmpty
            ? '_No summary._'
            : TextSafety.clean(summary);
        out
          ..writeln(text)
          ..writeln();
        if (findings.isEmpty) {
          out.writeln('**No findings.**');
        } else {
          out
            ..writeln('| # | Severity | Where | Finding |')
            ..writeln('|---|---|---|---|');
          for (final (index, finding) in findings.indexed) {
            out.writeln(
              '| ${index + 1} '
              '| ${finding.severity.icon} ${finding.severity.label} '
              '| `${_cell(finding.location)}` '
              '| ${_cell(TextSafety.clean(finding.title))} |',
            );
          }
          if (dropped > 0) {
            out
              ..writeln()
              ..writeln(
                '_$dropped more finding(s) left out by the per-review cap._',
              );
          }
        }
      case UnstructuredReview():
        out.writeln(
          "⚠️ The model's answer wasn't valid JSON. It's posted as one "
          'thread so it still gets a decision.',
        );
    }

    final selection = report.selection;
    final cut = [
      for (final file in selection.files)
        if (file.isTruncated) file.path,
    ];
    if (selection.skipped.isNotEmpty || cut.isNotEmpty) out.writeln();
    if (selection.skipped.isNotEmpty) {
      out.writeln(
        '**Not reviewed** (over the size limit): ${_paths(selection.skipped)}',
      );
    }
    if (cut.isNotEmpty) {
      out.writeln('**Only partly reviewed** (cut to fit): ${_paths(cut)}');
    }

    out
      ..writeln()
      ..writeln('> $_decisionNote');
    return out.toString();
  }

  String commentBody(PlannedComment comment, {required String model}) {
    final finding = comment.finding;
    final where = switch (comment.placement) {
      Placement.line => '',
      Placement.file when finding.line != null =>
        "_Line ${finding.line} isn't part of this diff, so this is on the "
            'file._\n\n',
      Placement.file => '',
      Placement.general =>
        '_General finding (${finding.file == null ? 'no file given' : 'about '
                      '`${finding.file}`'}), attached here so it still needs a '
            'decision._\n\n',
    };
    final out = StringBuffer()
      ..writeln(
        '**${finding.severity.icon} ${finding.severity.label}: '
        '${TextSafety.clean(finding.title)}**',
      )
      ..writeln()
      ..write(where)
      ..writeln(TextSafety.clean(finding.detail));
    final suggestion = finding.suggestion;
    if (suggestion != null) {
      out
        ..writeln()
        ..writeln('**Suggestion:**')
        ..writeln(TextSafety.clean(suggestion));
    }
    out
      ..writeln()
      ..writeln(
        '<sub>🤖 AI review by `$model`, advisory. Reply with your decision '
        '(accept, or ask for a change), then resolve this thread.</sub>',
      );
    return out.toString();
  }

  String unavailableBody({required String reason, required String model}) =>
      '### 🤖 AI review unavailable\n\n'
      'The review model (`$model`) gave no usable answer: '
      '${TextSafety.clean(reason)}.\n\n'
      'Nothing was reviewed for this push. The next push tries again, or '
      're-run the "AI review" workflow.';

  /// Plain-text version for `--print`.
  String consoleText(ReviewReport report, List<PlannedComment> comments) {
    final out = StringBuffer()..write(reviewBody(report));
    for (final comment in comments) {
      final where = comment.line == null
          ? '${comment.path} (${comment.placement.name})'
          : '${comment.path}:${comment.line}';
      out
        ..writeln()
        ..writeln('──── $where ────')
        ..write(commentBody(comment, model: report.model));
    }
    return out.toString();
  }

  static String _metaLine(ReviewReport report) {
    final scope = report.sinceSha == null
        ? 'the whole PR'
        : 'commits since `${_short(report.sinceSha!)}`';
    final tokens =
        report.promptTokens == null || report.completionTokens == null
        ? ''
        : ' · **Tokens:** ${report.promptTokens} in / '
              '${report.completionTokens} out';
    return '**Model:** `${report.model}` · '
        '**Reviewed:** `${_short(report.headSha)}` ($scope) · '
        '**Took:** ${report.took.inSeconds} s$tokens';
  }

  static String _short(String sha) =>
      sha.length > 7 ? sha.substring(0, 7) : sha;

  static String _cell(String text) =>
      text.replaceAll('|', r'\|').replaceAll('\n', ' ');

  static String _paths(List<String> paths) =>
      paths.map((path) => '`$path`').join(', ');
}
