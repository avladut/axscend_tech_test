import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/user_albums_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/widgets/album_tile.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A user's albums. Provides a fresh [UserAlbumsBloc] and starts loading.
class UserAlbumsScreen extends StatelessWidget {
  const new({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<UserAlbumsBloc>(param1: userId)..add(const LoadRequested()),
    child: const UserAlbumsView(),
  );
}

/// Renders the [UserAlbumsBloc]'s state. Tests pump it with a mock bloc.
class UserAlbumsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<UserAlbumsBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.albumsTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.albumsLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        builder: (context, data) => AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: data.user.name,
                count: data.albums.length,
              ),
              Expanded(
                child: data.albums.isEmpty
                    ? AppStatusView.empty(title: l10n.albumsEmptyTitle)
                    : RefreshIndicator(
                        onRefresh: bloc.refresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: data.albums.length,
                          itemBuilder: (context, index) {
                            final album = data.albums[index];
                            return AlbumTile(
                              album: album,
                              onTap: () => AlbumPhotosRoute(
                                userId: album.userId,
                                albumId: album.id,
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
