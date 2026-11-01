import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// A user and their albums.
final class UserAlbums extends Equatable {
  const new({required this.user, required this.albums});

  final User user;
  final List<Album> albums;

  @override
  List<Object?> get props => [user, albums];
}
