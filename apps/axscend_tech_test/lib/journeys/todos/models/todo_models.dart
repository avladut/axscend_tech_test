import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// A user and their todos.
final class UserTodos extends Equatable {
  const new({required this.user, required this.todos});

  final User user;
  final List<Todo> todos;

  int get doneCount => todos.where((todo) => todo.completed).length;

  /// The share done, from 0 to 1. 0 when there are no todos.
  double get progress => todos.isEmpty ? 0 : doneCount / todos.length;

  @override
  List<Object?> get props => [user, todos];
}

/// Which todos the list shows.
enum TodoFilter {
  all,
  done,
  pending;

  bool matches(Todo todo) => switch (this) {
    all => true,
    done => todo.completed,
    pending => !todo.completed,
  };

  /// The [todos] this filter shows, in their order.
  List<Todo> apply(List<Todo> todos) => [
    for (final todo in todos)
      if (matches(todo)) todo,
  ];
}
