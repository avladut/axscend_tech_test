part of 'users_bloc.dart';

/// Where the first page stands. Later pages have their own state in the
/// [PagedWindow].
enum UsersStatus { initial, loading, success, failure }

final class UsersState extends Equatable {
  const new({
    this.status = UsersStatus.initial,
    this.query = const UserQuery(),
    this.window = const PagedWindow(),
    this.listQuery = const UserQuery(),
    this.listRefreshed = false,
    this.failure,
  });

  final UsersStatus status;
  final UserQuery query;

  /// The pages in memory. Kept while a new search or sort loads.
  final PagedWindow<User> window;

  /// The query the [window] was loaded with. It differs from [query] while
  /// a new search or sort loads.
  final UserQuery listQuery;

  /// Whether the [window]'s first page was a refresh, so its later pages
  /// skip the cache too.
  final bool listRefreshed;

  /// Why the first page failed. Set only when [status] is
  /// [UsersStatus.failure]; the View puts it into words.
  final DataFailure? failure;

  UsersState copyWith({
    UsersStatus? status,
    UserQuery? query,
    PagedWindow<User>? window,
    UserQuery? listQuery,
    bool? listRefreshed,
    // A function, so the failure can be cleared back to null.
    DataFailure? Function()? failure,
  }) => UsersState(
    status: status ?? this.status,
    query: query ?? this.query,
    window: window ?? this.window,
    listQuery: listQuery ?? this.listQuery,
    listRefreshed: listRefreshed ?? this.listRefreshed,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    query,
    window,
    listQuery,
    listRefreshed,
    failure,
  ];
}
