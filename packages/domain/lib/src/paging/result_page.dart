import 'package:equatable/equatable.dart';

/// One page of a longer list, and how many items the whole list has.
final class ResultPage<T> extends Equatable {
  const new({required this.items, required this.total});

  final List<T> items;

  /// How many items match in all pages together.
  final int total;

  @override
  List<Object?> get props => [items, total];
}
