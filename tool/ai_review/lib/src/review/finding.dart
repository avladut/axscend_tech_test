/// How much a finding matters. Declared most severe first.
enum Severity {
  blocker('Blocker', '🔴'),
  major('Major', '🟠'),
  minor('Minor', '🟡'),
  nit('Nit', '⚪');

  new(this.label, this.icon);

  final String label;
  final String icon;

  /// Unknown or missing values become [minor]: worth a look, not alarming.
  static Severity parse(Object? value) {
    if (value is String) {
      for (final severity in values) {
        if (severity.name == value.trim().toLowerCase()) return severity;
      }
    }
    return minor;
  }
}

/// One issue the model raised.
class Finding {
  const new({
    required this.severity,
    required this.title,
    required this.detail,
    this.file,
    this.line,
    this.suggestion,
  });

  final Severity severity;
  final String title;
  final String detail;
  final String? file;
  final int? line;
  final String? suggestion;

  String get location => switch ((file, line)) {
    (final String file, final int line) => '$file:$line',
    (final String file, null) => file,
    _ => 'general',
  };
}

/// The model's answer, as far as it could be understood.
sealed class ParsedReview {
  const new();
}

/// The answer matched the expected JSON shape.
final class StructuredReview extends ParsedReview {
  const new({
    required this.summary,
    required this.findings,
    this.droppedFindings = 0,
  });

  final String summary;
  final List<Finding> findings;

  /// Findings beyond the cap, least severe first to go.
  final int droppedFindings;
}

/// The answer wasn't valid JSON. It's still shown, with a warning.
final class UnstructuredReview extends ParsedReview {
  const new(this.raw);

  final String raw;
}
