/// Makes model-written text safe to post on GitHub.
///
/// The diff under review is untrusted, and so is anything the model writes
/// about it. Two things could go wrong when that text is posted:
/// - an `@name` outside code would notify a real GitHub user or team;
/// - an HTML comment could fake the hidden marker this tool uses to find the
///   last reviewed commit.
abstract final class TextSafety {
  static const _zeroWidthSpace = '​';

  static final _mention = RegExp('(^|[^A-Za-z0-9_`])@(?=[A-Za-z0-9])');

  static String clean(String text) => _outsideCode(
    text.replaceAll('<!--', '<$_zeroWidthSpace!--'),
    (plain) => plain.replaceAllMapped(
      _mention,
      (match) => '${match[1]}@$_zeroWidthSpace',
    ),
  );

  /// Applies [transform] only outside ``` blocks and `inline code`, where
  /// GitHub doesn't turn `@name` into a mention anyway. Code stays exactly as
  /// written, so it can still be copied.
  static String _outsideCode(String text, String Function(String) transform) {
    final out = StringBuffer();
    final blocks = text.split('```');
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) out.write('```');
      if (i.isOdd) {
        out.write(blocks[i]);
        continue;
      }
      final spans = blocks[i].split('`');
      for (var j = 0; j < spans.length; j++) {
        if (j > 0) out.write('`');
        out.write(j.isOdd ? spans[j] : transform(spans[j]));
      }
    }
    return out.toString();
  }
}
