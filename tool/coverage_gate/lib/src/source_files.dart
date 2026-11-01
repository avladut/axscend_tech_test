import 'package:path/path.dart' as p;

/// Generated code isn't ours to test.
bool isGenerated(String path) {
  final name = p.basename(path);
  return name.endsWith('.g.dart') ||
      name.endsWith('.freezed.dart') ||
      name.startsWith('app_localizations');
}

final _blockComment = RegExp(r'/\*[\s\S]*?\*/');
final _lineComment = RegExp('//.*');
final _directive = RegExp(r'^(library|import|export|part)\b');

/// True when [source] has nothing to run: only `library`, `import`, `export`
/// and `part` directives, and comments. Barrel files are like this.
bool isDeclarationsOnly(String source) => source
    .replaceAll(_blockComment, '')
    .replaceAll(_lineComment, '')
    .split(';')
    .map((statement) => statement.trim())
    .where((statement) => statement.isNotEmpty)
    .every(_directive.hasMatch);
