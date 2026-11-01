import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/users/models/user_profile.dart';
import 'package:domain/domain.dart';

/// The user with [userId], with counts of their posts, albums and todos.
/// The lists are cached, so opening any of them afterwards is instant.
class UserProfileBloc extends LoadBloc<UserProfile> {
  new({
    required this.userId,
    required this._users,
    required this._posts,
    required this._albums,
    required this._todos,
  });

  final int userId;
  final UserRepository _users;
  final PostRepository _posts;
  final AlbumRepository _albums;
  final TodoRepository _todos;

  @override
  Future<UserProfile> load({required bool refresh}) async {
    final ((user, posts), (albums, todos)) = await loadBoth(
      loadBoth(
        _users.getUser(userId, refresh: refresh),
        _posts.getPosts(userId: userId, refresh: refresh),
      ),
      loadBoth(
        _albums.getAlbums(userId: userId, refresh: refresh),
        _todos.getTodos(userId: userId, refresh: refresh),
      ),
    );
    return UserProfile(
      user: user,
      postCount: posts.length,
      albumCount: albums.length,
      todoCount: todos.length,
      doneCount: todos.where((todo) => todo.completed).length,
    );
  }
}
