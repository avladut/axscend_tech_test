import 'package:axscend_tech_test/common/paging/paged_window.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

part 'users_event.dart';
part 'users_state.dart';

/// The users list, a page at a time. The backend searches and sorts, and at
/// most the [PagedWindow]'s limit of users is in memory.
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  new({
    required this._repository,
    this.searchDelay = const Duration(milliseconds: 300),
    PagedWindow<User> window = const PagedWindow(),
  }) : super(UsersState(window: window)) {
    // A newer load, search or sort replaces one still running, so an older
    // answer never overwrites a newer list.
    on<UsersListChanged>(_onListChanged, transformer: restartable());
    // Pages load side by side. Each page is fetched once at a time.
    on<UsersPageRequested>(_onPageRequested);
  }

  final UserRepository _repository;

  /// How long typing must pause before the search goes to the backend.
  final Duration searchDelay;

  Future<void> _onListChanged(
    UsersListChanged event,
    Emitter<UsersState> emit,
  ) async {
    final query = switch (event) {
      UsersLoadRequested() => state.query,
      UsersSearchChanged(:final text) => state.query.copyWith(text: text),
      UsersSortChanged(:final sort) => state.query.copyWith(sort: sort),
    };
    if (query != state.query) {
      // Kept straight away, so a sort picked while a search waits still
      // uses the typed text.
      emit(state.copyWith(query: query));
    } else if (event is! UsersLoadRequested) {
      return;
    }
    if (event is UsersSearchChanged) {
      // A newer keystroke restarts this handler, so only the last one
      // reaches the backend.
      await Future<void>.delayed(searchDelay);
      if (emit.isDone) return;
    }

    emit(state.copyWith(status: UsersStatus.loading, failure: () => null));
    try {
      final first = await _repository.getUsersPage(
        PageRequest(index: 0, size: state.window.pageSize),
        query: query,
        refresh: event is UsersLoadRequested && event.refresh,
      );
      emit(
        state.copyWith(
          status: UsersStatus.success,
          window: state.window.cleared().withPage(
            0,
            first.items,
            total: first.total,
          ),
        ),
      );
    } on DataFailure catch (failure) {
      emit(state.copyWith(status: UsersStatus.failure, failure: () => failure));
    }
  }

  Future<void> _onPageRequested(
    UsersPageRequested event,
    Emitter<UsersState> emit,
  ) async {
    final page = event.page;
    final window = state.window;
    if (!window.exists(page) ||
        window.isLoaded(page) ||
        window.isLoading(page)) {
      return;
    }
    final query = state.query;
    emit(state.copyWith(window: window.withLoading(page)));
    try {
      final result = await _repository.getUsersPage(
        PageRequest(index: page, size: window.pageSize),
        query: query,
      );
      if (!_stillWanted(page, query)) return;
      emit(
        state.copyWith(
          window: state.window.withPage(
            page,
            result.items,
            total: result.total,
          ),
        ),
      );
    } on DataFailure {
      if (!_stillWanted(page, query)) return;
      emit(state.copyWith(window: state.window.withFailed(page)));
    }
  }

  /// Whether an answer for [page] still belongs: the list wasn't searched,
  /// sorted or reloaded since it was asked for.
  bool _stillWanted(int page, UserQuery query) =>
      state.query == query && state.window.isLoading(page);
}
