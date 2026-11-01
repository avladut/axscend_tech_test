import 'package:equatable/equatable.dart';

/// The pages of a long list that are in memory: at most [maxPages] at once.
///
/// Adding a page drops the pages farthest from it, so the window follows the
/// scroll. A row whose page isn't in memory shows a placeholder and asks for
/// its page again.
///
/// `maxPages × pageSize` must cover more rows than one screen shows, plus
/// the list's scroll cache, or rows on screen would be dropped. Three pages
/// of 20 cover screens up to about 2,400 px tall.
final class PagedWindow<T> extends Equatable {
  const new({
    this.pageSize = 20,
    this.maxPages = 3,
    this.total,
    this.pages = const {},
    this.loading = const {},
    this.failed = const {},
  });

  final int pageSize;
  final int maxPages;

  /// How many items the whole list has. Null until the first page arrives.
  final int? total;

  /// The pages in memory, by index from 0.
  final Map<int, List<T>> pages;

  /// The pages being fetched.
  final Set<int> loading;

  /// The pages whose last fetch failed.
  final Set<int> failed;

  /// The page that holds item [index].
  int pageOf(int index) => index ~/ pageSize;

  /// The item at [index], or null when its page isn't in memory.
  T? itemAt(int index) {
    final items = pages[pageOf(index)];
    final offset = index % pageSize;
    return items != null && offset < items.length ? items[offset] : null;
  }

  bool isLoaded(int page) => pages.containsKey(page);
  bool isLoading(int page) => loading.contains(page);
  bool hasFailed(int page) => failed.contains(page);

  /// Whether [page] is part of the list, as far as [total] says.
  bool exists(int page) {
    final total = this.total;
    return total != null && page >= 0 && page * pageSize < total;
  }

  /// How many items are in memory.
  int get itemsInMemory =>
      pages.values.fold(0, (count, items) => count + items.length);

  /// [page] is being fetched.
  PagedWindow<T> withLoading(int page) =>
      _copy(loading: {...loading, page}, failed: {...failed}..remove(page));

  /// The fetch of [page] failed.
  PagedWindow<T> withFailed(int page) =>
      _copy(loading: {...loading}..remove(page), failed: {...failed, page});

  /// [items] arrived as [page], and the list now has [total] items. The
  /// pages farthest from [page] are dropped to stay within [maxPages].
  PagedWindow<T> withPage(int page, List<T> items, {required int total}) {
    final kept = {...pages, page: items};
    while (kept.length > maxPages) {
      final farthest = kept.keys.reduce(
        (a, b) => (a - page).abs() >= (b - page).abs() ? a : b,
      );
      kept.remove(farthest);
    }
    return _copy(
      total: total,
      pages: kept,
      loading: {...loading}..remove(page),
      failed: {...failed}..remove(page),
    );
  }

  /// Empty, with the same page size and limit: for a new search or sort.
  PagedWindow<T> cleared() =>
      PagedWindow(pageSize: pageSize, maxPages: maxPages);

  PagedWindow<T> _copy({
    int? total,
    Map<int, List<T>>? pages,
    Set<int>? loading,
    Set<int>? failed,
  }) => PagedWindow(
    pageSize: pageSize,
    maxPages: maxPages,
    total: total ?? this.total,
    pages: pages ?? this.pages,
    loading: loading ?? this.loading,
    failed: failed ?? this.failed,
  );

  @override
  List<Object?> get props => [
    pageSize,
    maxPages,
    total,
    pages,
    loading,
    failed,
  ];
}
