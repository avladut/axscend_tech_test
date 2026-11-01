import 'package:equatable/equatable.dart';

/// A reply to a `Post`. Anyone can comment, so the commenter is a name and
/// an email, not a `User`.
class Comment extends Equatable {
  const new({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  final int id;
  final int postId;

  /// The comment's subject line.
  final String name;

  /// Who wrote it.
  final String email;

  final String body;

  @override
  List<Object?> get props => [id, postId, name, email, body];
}
