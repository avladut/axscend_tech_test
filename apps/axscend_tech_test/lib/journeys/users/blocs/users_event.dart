part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Events that start the list again from its first page.
sealed class UsersListChanged extends UsersEvent {
  const new();
}

/// Load the first page. With [refresh], ask the backend again instead of
/// using what is cached.
final class UsersLoadRequested extends UsersListChanged {
  const new({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

/// The search text changed to [text].
final class UsersSearchChanged extends UsersListChanged {
  const new(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// The user picked another [sort].
final class UsersSortChanged extends UsersListChanged {
  const new(this.sort);

  final UserSort sort;

  @override
  List<Object?> get props => [sort];
}

/// A row of [page] came on screen, or "Try again" was tapped on one, and
/// the page isn't in memory.
final class UsersPageRequested extends UsersEvent {
  const new(this.page);

  final int page;

  @override
  List<Object?> get props => [page];
}
