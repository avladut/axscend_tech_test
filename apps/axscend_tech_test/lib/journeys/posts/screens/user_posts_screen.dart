import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A user's posts. Provides a fresh [UserPostsBloc] and starts loading.
class UserPostsScreen extends StatelessWidget {
  const new({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<UserPostsBloc>(param1: userId)..add(const LoadRequested()),
    child: const UserPostsView(),
  );
}

/// Renders the [UserPostsBloc]'s state. Tests pump it with a mock bloc.
class UserPostsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<UserPostsBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postsTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.postsLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        builder: (context, data) => AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(title: data.user.name, count: data.posts.length),
              Expanded(
                child: data.posts.isEmpty
                    ? AppStatusView.empty(title: l10n.postsEmptyTitle)
                    : RefreshIndicator(
                        onRefresh: bloc.refresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: data.posts.length,
                          itemBuilder: (context, index) {
                            final post = data.posts[index];
                            return AppListTile(
                              title: post.title,
                              subtitle: post.body,
                              onTap: () => PostRoute(
                                userId: post.userId,
                                postId: post.id,
                              ).go(context),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
