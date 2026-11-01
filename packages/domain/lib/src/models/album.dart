import 'package:equatable/equatable.dart';

/// A `User`'s collection of photos.
class Album extends Equatable {
  const new({required this.id, required this.userId, required this.title});

  final int id;

  /// The owner.
  final int userId;

  final String title;

  @override
  List<Object?> get props => [id, userId, title];
}
