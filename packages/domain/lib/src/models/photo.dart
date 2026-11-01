import 'package:equatable/equatable.dart';

/// One picture in an `Album`.
class Photo extends Equatable {
  const new({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  final int id;
  final int albumId;
  final String title;

  /// The full-size image.
  final Uri url;

  /// A small version for grids and lists.
  final Uri thumbnailUrl;

  @override
  List<Object?> get props => [id, albumId, title, url, thumbnailUrl];
}
