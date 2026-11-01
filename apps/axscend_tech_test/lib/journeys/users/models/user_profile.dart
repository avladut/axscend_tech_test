import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// A user, and how much they have of each thing.
final class UserProfile extends Equatable {
  const new({
    required this.user,
    required this.postCount,
    required this.albumCount,
    required this.todoCount,
    required this.doneCount,
  });

  final User user;
  final int postCount;
  final int albumCount;
  final int todoCount;

  /// How many of the [todoCount] todos are done.
  final int doneCount;

  /// The share of todos done, from 0 to 1. 0 when there are none.
  double get progress => todoCount == 0 ? 0 : doneCount / todoCount;

  @override
  List<Object?> get props => [
    user,
    postCount,
    albumCount,
    todoCount,
    doneCount,
  ];
}
