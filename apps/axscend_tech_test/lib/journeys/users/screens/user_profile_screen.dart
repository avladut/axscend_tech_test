import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/models/user_profile.dart';
import 'package:axscend_tech_test/journeys/users/widgets/profile_header.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A user's profile, and the way to their posts, albums and todos. Provides
/// a fresh [UserProfileBloc] and starts loading.
class UserProfileScreen extends StatelessWidget {
  const new({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<UserProfileBloc>(param1: userId)..add(const LoadRequested()),
    child: const UserProfileView(),
  );
}

/// Renders the [UserProfileBloc]'s state. Tests pump it with a mock bloc.
class UserProfileView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<UserProfileBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.profileLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        builder: (context, profile) => AppPage(
          child: RefreshIndicator(
            onRefresh: bloc.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ProfileHeader(user: profile.user),
                _ProfileDetails(profile: profile),
                _ProfileActivity(profile: profile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contact details, address and company.
class _ProfileDetails extends StatelessWidget {
  const new({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = profile.user;
    final address = user.address;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: l10n.profileContact),
        AppInfoRow(
          icon: Icons.email_outlined,
          label: l10n.profileEmail,
          value: user.email,
        ),
        AppInfoRow(
          icon: Icons.phone_outlined,
          label: l10n.profilePhone,
          value: user.phone,
        ),
        AppInfoRow(
          icon: Icons.language,
          label: l10n.profileWebsite,
          value: user.website,
        ),
        AppSectionHeader(title: l10n.profileAddress),
        AppInfoRow(
          icon: Icons.place_outlined,
          label: l10n.profileAddress,
          value: l10n.profileAddressLine(
            address.street,
            address.suite,
            address.city,
            address.zipcode,
          ),
        ),
        AppSectionHeader(title: l10n.profileCompany),
        AppInfoRow(
          icon: Icons.business_outlined,
          label: l10n.profileCompany,
          value: user.company.name,
        ),
        AppInfoRow(
          icon: Icons.format_quote_outlined,
          label: l10n.profileCatchPhrase,
          value: user.company.catchPhrase,
        ),
      ],
    );
  }
}

/// The way to the user's posts, albums and todos, with how much of each.
class _ProfileActivity extends StatelessWidget {
  const new({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userId = profile.user.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: l10n.profileActivity),
        AppListTile(
          leading: const Icon(Icons.article_outlined),
          title: l10n.profilePosts,
          subtitle: l10n.profilePostsCount(profile.postCount),
          onTap: () => UserPostsRoute(userId: userId).go(context),
        ),
        AppListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: l10n.profileAlbums,
          subtitle: l10n.profileAlbumsCount(profile.albumCount),
          onTap: () => UserAlbumsRoute(userId: userId).go(context),
        ),
        AppListTile(
          leading: const Icon(Icons.checklist),
          title: l10n.profileTodos,
          subtitle: l10n.todosDoneCount(profile.doneCount, profile.todoCount),
          trailing: AppProgressRing(
            value: profile.progress,
            semanticLabel: l10n.todosProgressLabel,
          ),
          onTap: () => UserTodosRoute(userId: userId).go(context),
        ),
      ],
    );
  }
}
