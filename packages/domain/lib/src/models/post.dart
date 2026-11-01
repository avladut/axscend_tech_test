import 'package:equatable/equatable.dart';

/// Something a `User` wrote. It has comments.
class Post extends Equatable {
  const new({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;

  /// The author.
  final int userId;

  final String title;
  final String body;

  @override
  List<Object?> get props => [id, userId, title, body];
}
