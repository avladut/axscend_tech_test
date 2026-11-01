import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/user_albums.dart';
import 'package:domain/domain.dart';

/// The user with [userId] and their albums.
class UserAlbumsBloc extends LoadBloc<UserAlbums> {
  new({required this.userId, required this._users, required this._albums});

  final int userId;
  final UserRepository _users;
  final AlbumRepository _albums;

  @override
  Future<UserAlbums> load({required bool refresh}) async {
    final (user, albums) = await loadBoth(
      _users.getUser(userId, refresh: refresh),
      _albums.getAlbums(userId: userId, refresh: refresh),
    );
    return UserAlbums(user: user, albums: albums);
  }
}
