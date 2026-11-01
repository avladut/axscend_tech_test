import 'package:axscend_tech_test/common/paging/paged_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PagedWindow, () {
    const empty = PagedWindow<String>(pageSize: 2, maxPages: 2);

    test('keeps at most 3 pages of 20 unless told otherwise', () {
      const window = PagedWindow<String>();
      expect(window.pageSize * window.maxPages, 60);
    });

    test('knows nothing until the first page arrives', () {
      expect(empty.total, isNull);
      expect(empty.exists(0), isFalse);
      expect(empty.itemAt(0), isNull);
    });

    test('finds each item in its page', () {
      final window = empty.withPage(1, ['c', 'd'], total: 5);

      expect(window.pageOf(3), 1);
      expect(window.itemAt(2), 'c');
      expect(window.itemAt(3), 'd');
      expect(window.itemAt(0), isNull, reason: 'page 0 is not in memory');
    });

    test('a short last page has no item past its end', () {
      final window = empty.withPage(2, ['e'], total: 5);

      expect(window.itemAt(4), 'e');
      expect(window.itemAt(5), isNull);
    });

    test('knows which pages exist from the total', () {
      final window = empty.withPage(0, ['a', 'b'], total: 5);

      expect(
        [for (var page = -1; page <= 3; page++) window.exists(page)],
        [false, true, true, true, false],
      );
    });

    test('drops the page farthest from the one that arrived', () {
      final down = empty
          .withPage(0, ['a', 'b'], total: 10)
          .withPage(1, ['c', 'd'], total: 10)
          .withPage(2, ['e', 'f'], total: 10);
      expect(down.pages.keys, unorderedEquals([1, 2]));
      expect(down.itemsInMemory, 4);

      // Scrolling back up drops the page at the bottom instead.
      final up = down.withPage(0, ['a', 'b'], total: 10);
      expect(up.pages.keys, unorderedEquals([0, 1]));
    });

    test('tracks a page from loading to loaded, or to failed', () {
      final loading = empty.withLoading(1);
      expect(loading.isLoading(1), isTrue);

      final failed = loading.withFailed(1);
      expect(failed.isLoading(1), isFalse);
      expect(failed.hasFailed(1), isTrue);

      final retried = failed.withLoading(1);
      expect(retried.hasFailed(1), isFalse);

      final loaded = retried.withPage(1, ['c'], total: 3);
      expect(loaded.isLoading(1), isFalse);
      expect(loaded.isLoaded(1), isTrue);
    });

    test('takes the newest total', () {
      final window = empty.withPage(0, ['a', 'b'], total: 10).withPage(1, [
        'c',
        'd',
      ], total: 12);
      expect(window.total, 12);
    });

    test('clears everything but its size and limit', () {
      final window = empty
          .withPage(0, ['a', 'b'], total: 10)
          .withLoading(1)
          .withFailed(2);

      expect(window.cleared(), empty);
    });
  });
}
