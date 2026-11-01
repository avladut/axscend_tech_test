import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// An album and its photos.
final class AlbumPhotos extends Equatable {
  const new({required this.album, required this.photos});

  final Album album;
  final List<Photo> photos;

  @override
  List<Object?> get props => [album, photos];
}
