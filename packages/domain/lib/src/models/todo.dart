import 'package:equatable/equatable.dart';

/// A task on a `User`'s list.
class Todo extends Equatable {
  const new({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  final int id;

  /// Whose list it's on.
  final int userId;

  final String title;
  final bool completed;

  @override
  List<Object?> get props => [id, userId, title, completed];
}
