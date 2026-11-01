import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/common/paging/paged_window.dart';
import 'package:axscend_tech_test/common/widgets/data_failure_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:axscend_tech_test/journeys/users/widgets/user_tile.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The start page. Provides a fresh [UsersBloc] and starts loading.
class UsersScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<UsersBloc>()..add(const UsersLoadRequested()),
    child: const UsersView(),
  );
}

/// Renders the [UsersBloc]'s state. Tests pump it with a mock bloc.
class UsersView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<UsersBloc>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usersTitle)),
      body: _UsersContent(state: state),
    );
  }
}

/// The search field, the header with the count and sort menu, and the list
/// area. The search field stays in every state, so a search that failed can
/// still be cleared.
class _UsersContent extends StatelessWidget {
  const new({required this.state});

  final UsersState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<UsersBloc>();
    final query = state.query;
    final window = state.window;
    final count = window.total;
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            hint: l10n.usersSearchHint,
            clearTooltip: l10n.usersSearchClear,
            value: query.text,
            onChanged: (text) => bloc.add(UsersSearchChanged(text)),
          ),
          AppSectionHeader(
            title: query.isSearching
                ? l10n.usersResultsHeader
                : l10n.usersAllHeader,
            count: count,
            trailing: AppSortButton<UserSort>(
              tooltip: l10n.usersSortTooltip,
              selected: query.sort,
              choices: [
                for (final sort in UserSort.values)
                  AppChoice(value: sort, label: sort.label(l10n)),
              ],
              onSelected: (sort) => bloc.add(UsersSortChanged(sort)),
            ),
          ),
          Expanded(
            child: switch (state) {
              UsersState(status: UsersStatus.failure, :final failure?) =>
                DataFailureView(
                  failure: failure,
                  onRetry: () =>
                      bloc.add(const UsersLoadRequested(refresh: true)),
                ),
              // Nothing to show yet. A new list that has rows keeps
              // showing them while it reloads.
              UsersState(window: PagedWindow(total: null)) ||
              UsersState(
                status: UsersStatus.loading,
                window: PagedWindow(total: 0),
              ) => AppStatusView.loading(title: l10n.usersLoading),
              UsersState(window: PagedWindow(total: 0))
                  when !query.isSearching =>
                AppStatusView.empty(title: l10n.usersEmptyTitle),
              UsersState(window: PagedWindow(total: 0)) => AppStatusView.empty(
                title: l10n.usersNoMatchTitle(query.search),
                message: l10n.usersNoMatchMessage,
              ),
              _ => RefreshIndicator(
                onRefresh: () => _refresh(bloc),
                // Builds only the rows on screen, from the pages in
                // memory. Any other row shows a placeholder until its
                // page arrives.
                child: ListView.builder(
                  // Pull-to-refresh works even when the list is short.
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: count ?? 0,
                  itemBuilder: (context, index) {
                    if (window.itemAt(index) case final user?) {
                      return UserTile(
                        user: user,
                        onTap: () =>
                            UserAlbumsRoute(userId: user.id).go(context),
                      );
                    }
                    final page = window.pageOf(index);
                    void request() => bloc.add(UsersPageRequested(page));
                    return window.hasFailed(page)
                        ? _FailedUserRow(onRetry: request)
                        : _PendingUserRow(onShown: request);
                  },
                ),
              ),
            },
          ),
        ],
      ),
    );
  }

  /// Asks for fresh users and completes when the load has finished, so the
  /// refresh spinner stays until then. Also completes if the bloc closes
  /// first, such as when the screen is left.
  Future<void> _refresh(UsersBloc bloc) {
    bloc.add(const UsersLoadRequested(refresh: true));
    return bloc.stream.firstWhere(
      (state) => state.status != UsersStatus.loading,
      orElse: () => bloc.state,
    );
  }
}

/// A row whose page isn't in memory. Asks for it whenever it is built: the
/// bloc ignores a page that is already there or on its way.
class _PendingUserRow extends StatefulWidget {
  const new({required this.onShown});

  final VoidCallback onShown;

  @override
  State<_PendingUserRow> createState() => _PendingUserRowState();
}

class _PendingUserRowState extends State<_PendingUserRow> {
  @override
  void initState() {
    super.initState();
    widget.onShown();
  }

  @override
  void didUpdateWidget(_PendingUserRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The list changed (a new search, a page dropped): ask again.
    widget.onShown();
  }

  @override
  Widget build(BuildContext context) =>
      AppListTilePlaceholder(semanticLabel: context.l10n.usersRowLoading);
}

/// A row whose page failed to load, with a way to try again.
class _FailedUserRow extends StatelessWidget {
  const new({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppListTile(
      leading: const Icon(Icons.refresh),
      title: l10n.usersRowFailed,
      subtitle: l10n.tryAgain,
      trailing: const SizedBox.shrink(),
      onTap: onRetry,
    );
  }
}

extension on UserSort {
  String label(AppLocalizations l10n) => switch (this) {
    UserSort.nameAscending => l10n.usersSortNameAscending,
    UserSort.nameDescending => l10n.usersSortNameDescending,
    UserSort.company => l10n.usersSortCompany,
    UserSort.city => l10n.usersSortCity,
  };
}
