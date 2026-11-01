import 'package:domain/src/failures/data_failure.dart';
import 'package:domain/src/models/comment.dart';
import 'package:domain/src/models/post.dart';

/// Reads posts and their comments.
///
/// Every method throws a [DataFailure] when it can't deliver: an
/// [OfflineFailure], a [ServerFailure] or an [UnexpectedDataFailure], and
/// [getPost] also a [NotFoundFailure]. `refresh: true` skips any cache and
/// asks the backend again.
abstract interface class PostRepository {
  /// One user's posts, or everyone's when [userId] is null. A user with no
  /// posts, or an unknown one, gives an empty list.
  Future<List<Post>> getPosts({int? userId, bool refresh = false});

  /// The post with [id]. Throws a [NotFoundFailure] when there is none.
  Future<Post> getPost(int id, {bool refresh = false});

  /// The comments on the post with [postId]. An unknown post gives an empty
  /// list.
  Future<List<Comment>> getComments(int postId, {bool refresh = false});
}
