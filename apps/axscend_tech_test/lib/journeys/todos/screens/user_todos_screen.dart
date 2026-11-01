import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/models/todo_models.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A user's todos. Provides a fresh [UserTodosBloc] and starts loading.
class UserTodosScreen extends StatelessWidget {
  const new({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<UserTodosBloc>(param1: userId)..add(const LoadRequested()),
    child: const UserTodosView(),
  );
}

/// Renders the [UserTodosBloc]'s state. Tests pump it with a mock bloc.
class UserTodosView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<UserTodosBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.todosTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.todosLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        builder: (context, data) =>
            _TodosContent(data: data, onRefresh: bloc.refresh),
      ),
    );
  }
}

/// The progress, the filter and the list. The filter is this widget's own
/// state: it only picks which of the loaded todos show.
class _TodosContent extends StatefulWidget {
  const new({required this.data, required this.onRefresh});

  final UserTodos data;
  final Future<void> Function() onRefresh;

  @override
  State<_TodosContent> createState() => _TodosContentState();
}

class _TodosContentState extends State<_TodosContent> {
  TodoFilter _filter = TodoFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = widget.data;
    final todos = data.todos;
    final shown = _filter.apply(todos);
    final done = data.doneCount;
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: data.user.name,
            count: shown.length,
            trailing: AppProgressRing(
              value: data.progress,
              semanticLabel: l10n.todosProgressLabel,
            ),
          ),
          AppChoiceChips<TodoFilter>(
            choices: [
              AppChoice(
                value: TodoFilter.all,
                label: l10n.todosFilterAll(todos.length),
              ),
              AppChoice(
                value: TodoFilter.done,
                label: l10n.todosFilterDone(done),
              ),
              AppChoice(
                value: TodoFilter.pending,
                label: l10n.todosFilterPending(todos.length - done),
              ),
            ],
            selected: _filter,
            onSelected: (filter) => setState(() => _filter = filter),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: shown.isEmpty
                ? AppStatusView.empty(
                    title: switch (_filter) {
                      TodoFilter.all => l10n.todosEmptyTitle,
                      TodoFilter.done => l10n.todosNoneDoneTitle,
                      TodoFilter.pending => l10n.todosNonePendingTitle,
                    },
                  )
                : RefreshIndicator(
                    onRefresh: widget.onRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: shown.length,
                      itemBuilder: (context, index) => AppCheckRow(
                        title: shown[index].title,
                        done: shown[index].completed,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
