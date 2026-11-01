import 'package:equatable/equatable.dart';

/// The orders a list of users can come in.
enum UserSort { nameAscending, nameDescending, company, city }

/// Which users to list, and in what order.
final class UserQuery extends Equatable {
  const new({this.text = '', this.sort = UserSort.nameAscending});

  /// Search text, as typed. Spaces around it are ignored.
  final String text;
  final UserSort sort;

  /// [text] without the spaces around it.
  String get search => text.trim();

  /// Whether [text] narrows the list. Spaces alone don't.
  bool get isSearching => search.isNotEmpty;

  UserQuery copyWith({String? text, UserSort? sort}) =>
      UserQuery(text: text ?? this.text, sort: sort ?? this.sort);

  @override
  List<Object?> get props => [text, sort];
}
