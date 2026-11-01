import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:axscend_tech_test/journeys/posts/widgets/comment_card.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One post and its comments. Provides a fresh [PostBloc] and starts
/// loading.
class PostScreen extends StatelessWidget {
  const new({required this.address, super.key});

  final PostAddress address;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PostBloc>(param1: address)..add(const LoadRequested()),
    child: const PostView(),
  );
}

/// Renders the [PostBloc]'s state. Tests pump it with a mock bloc.
class PostView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<PostBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.postLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        builder: (context, data) => AppPage(
          child: RefreshIndicator(
            onRefresh: bloc.refresh,
            // The post first, then one row per comment, built as they
            // scroll into view.
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 1 + (data.comments.isEmpty ? 1 : data.comments.length),
              itemBuilder: (context, index) {
                if (index == 0) return _PostBody(details: data);
                if (data.comments.isEmpty) {
                  return AppStatusView.empty(title: l10n.commentsEmptyTitle);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CommentCard(comment: data.comments[index - 1]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The post's title and text, and the header above its comments.
class _PostBody extends StatelessWidget {
  const new({required this.details});

  final PostDetails details;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(details.post.title, style: context.textStyles.titleLarge),
      const SizedBox(height: AppSpacing.md),
      Text(details.post.body, style: context.textStyles.bodyLarge),
      AppSectionHeader(
        title: context.l10n.commentsHeader,
        count: details.comments.length,
      ),
    ],
  );
}
