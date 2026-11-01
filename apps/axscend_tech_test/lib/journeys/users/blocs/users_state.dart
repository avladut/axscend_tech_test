part of 'users_bloc.dart';

/// Where the first page stands. Later pages have their own state in the
/// [PagedWindow].
enum UsersStatus { initial, loading, success, failure }

final class UsersState extends Equatable {
  const new({
    this.status = UsersStatus.initial,
    this.query = const UserQuery(),
    this.window = const PagedWindow(),
    this.failure,
  });

  final UsersStatus status;
  final UserQuery query;

  /// The pages in memory. Kept while a new search or sort loads.
  final PagedWindow<User> window;

  /// Why the first page failed. Set only when [status] is
  /// [UsersStatus.failure]; the View puts it into words.
  final DataFailure? failure;

  UsersState copyWith({
    UsersStatus? status,
    UserQuery? query,
    PagedWindow<User>? window,
    // A function, so the failure can be cleared back to null.
    DataFailure? Function()? failure,
  }) => UsersState(
    status: status ?? this.status,
    query: query ?? this.query,
    window: window ?? this.window,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, query, window, failure];
}
