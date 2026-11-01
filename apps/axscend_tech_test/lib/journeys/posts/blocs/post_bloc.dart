import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:domain/domain.dart';

/// The post at [address] and its comments. A post that isn't that user's
/// is "not found", so a mistyped link can't mix two users up.
class PostBloc extends LoadBloc<PostDetails> {
  new({required this.address, required this._posts});

  final PostAddress address;
  final PostRepository _posts;

  @override
  Future<PostDetails> load({required bool refresh}) async {
    final (post, comments) = await loadBoth(
      _posts.getPost(address.postId, refresh: refresh),
      _posts.getComments(address.postId, refresh: refresh),
    );
    if (post.userId != address.userId) {
      throw NotFoundFailure(
        detail: "post ${post.id} is not user ${address.userId}'s",
      );
    }
    return PostDetails(post: post, comments: comments);
  }
}
