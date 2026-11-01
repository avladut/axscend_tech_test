import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:domain/domain.dart';

/// The user with [userId] and their posts.
class UserPostsBloc extends LoadBloc<UserPosts> {
  new({required this.userId, required this._users, required this._posts});

  final int userId;
  final UserRepository _users;
  final PostRepository _posts;

  @override
  Future<UserPosts> load({required bool refresh}) async {
    final (user, posts) = await loadBoth(
      _users.getUser(userId, refresh: refresh),
      _posts.getPosts(userId: userId, refresh: refresh),
    );
    return UserPosts(user: user, posts: posts);
  }
}
