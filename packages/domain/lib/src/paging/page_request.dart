import 'package:equatable/equatable.dart';

/// Which part of a long list to fetch: page [index] (from 0), [size] items
/// per page.
final class PageRequest extends Equatable {
  const new({required this.index, required this.size})
    : assert(index >= 0, 'index starts at 0'),
      assert(size > 0, 'a page holds at least one item');

  final int index;
  final int size;

  /// The position of the page's first item in the whole list.
  int get offset => index * size;

  @override
  List<Object?> get props => [index, size];
}
