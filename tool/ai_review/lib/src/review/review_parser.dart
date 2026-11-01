import 'dart:convert';

import 'package:ai_review/src/review/finding.dart';

/// Turns the model's answer into a [ParsedReview].
///
/// Lenient on purpose: a local model may wrap the JSON in a code fence, add
/// fields, or send a line number as a string. Anything that can't be
/// understood at all becomes an [UnstructuredReview] instead of an error.
class ReviewParser {
  const new({this.maxFindings = 10});

  final int maxFindings;

  /// The shape the model is asked for (also sent as a JSON schema).
  static const Map<String, Object?> schema = {
    'type': 'object',
    'properties': {
      'summary': {'type': 'string'},
      'findings': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'severity': {
              'type': 'string',
              'enum': ['blocker', 'major', 'minor', 'nit'],
            },
            'file': {'type': 'string'},
            'line': {'type': 'integer'},
            'title': {'type': 'string'},
            'detail': {'type': 'string'},
            'suggestion': {'type': 'string'},
          },
          'required': ['severity', 'file', 'line', 'title', 'detail'],
        },
      },
    },
    'required': ['summary', 'findings'],
  };

  ParsedReview parse(String answer) {
    final json = _decodeObject(answer);
    if (json == null) return UnstructuredReview(answer.trim());

    final rawFindings = json['findings'];
    final findings = <Finding>[
      if (rawFindings is List)
        for (final item in rawFindings)
          if (item is Map<String, Object?>) ?_finding(item),
    ];
    // Stable sort: most severe first, the model's order within a severity.
    final ordered = [
      for (final severity in Severity.values)
        ...findings.where((finding) => finding.severity == severity),
    ];
    final kept = ordered.take(maxFindings).toList();

    final summary = json['summary'];
    return StructuredReview(
      summary: summary is String ? summary.trim() : '',
      findings: kept,
      droppedFindings: ordered.length - kept.length,
    );
  }

  /// The JSON object in [answer], ignoring code fences and any text around
  /// it. Null when there's no object to decode.
  static Map<String, Object?>? _decodeObject(String answer) {
    final start = answer.indexOf('{');
    final end = answer.lastIndexOf('}');
    if (start == -1 || end <= start) return null;
    try {
      final decoded = jsonDecode(answer.substring(start, end + 1));
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static Finding? _finding(Map<String, Object?> json) {
    final title = _text(json['title']);
    final detail = _text(json['detail']);
    if (title == null && detail == null) return null;
    return Finding(
      severity: Severity.parse(json['severity']),
      title: title ?? _firstWords(detail!),
      detail: detail ?? '',
      file: _text(json['file']),
      line: _line(json['line']),
      suggestion: _text(json['suggestion']),
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Positive line numbers only, as an int or a numeric string.
  static int? _line(Object? value) {
    final line = switch (value) {
      final int number => number,
      final String text => int.tryParse(text.trim()),
      _ => null,
    };
    return line != null && line > 0 ? line : null;
  }

  static String _firstWords(String text) =>
      text.length <= 80 ? text : '${text.substring(0, 77)}...';
}
