import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Which post: its author and its id, as in `/users/1/posts/2`.
typedef PostAddress = ({int userId, int postId});

/// A user and their posts.
final class UserPosts extends Equatable {
  const new({required this.user, required this.posts});

  final User user;
  final List<Post> posts;

  @override
  List<Object?> get props => [user, posts];
}

/// A post and its comments.
final class PostDetails extends Equatable {
  const new({required this.post, required this.comments});

  final Post post;
  final List<Comment> comments;

  @override
  List<Object?> get props => [post, comments];
}
