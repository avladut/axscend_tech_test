import 'package:coverage_gate/coverage_gate.dart';
import 'package:test/test.dart';

void main() {
  test('isGenerated spots generated files', () {
    expect(isGenerated('lib/app/router.g.dart'), isTrue);
    expect(isGenerated('lib/models/user.freezed.dart'), isTrue);
    expect(isGenerated('lib/l10n/app_localizations_en.dart'), isTrue);
    expect(isGenerated('lib/app/router.dart'), isFalse);
  });

  group('isDeclarationsOnly', () {
    test('is true for a barrel file with comments', () {
      expect(
        isDeclarationsOnly('''
/// What the app is about.
library;

// The models.
export 'src/user.dart';
export 'src/post.dart'
    show Post, PostId;
/* Contracts. */
import 'package:meta/meta.dart';
part 'src/part.dart';
'''),
        isTrue,
      );
    });

    test('is true for an empty file', () {
      expect(isDeclarationsOnly(''), isTrue);
    });

    test('is false as soon as there is code', () {
      expect(isDeclarationsOnly("export 'a.dart';\nint x = 1;"), isFalse);
      expect(isDeclarationsOnly('class User {}'), isFalse);
      expect(
        isDeclarationsOnly("final url = Uri.parse('https://example.test');"),
        isFalse,
      );
    });
  });
}
