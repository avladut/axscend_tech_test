import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/album_photos_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:axscend_tech_test/journeys/albums/widgets/photo_grid.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An album's photos as a grid of thumbnails. Provides a fresh
/// [AlbumPhotosBloc] and starts loading.
class AlbumPhotosScreen extends StatelessWidget {
  const new({required this.address, super.key});

  final AlbumAddress address;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<AlbumPhotosBloc>(param1: address)..add(const LoadRequested()),
    child: const AlbumPhotosView(),
  );
}

/// Renders the [AlbumPhotosBloc]'s state. Tests pump it with a mock bloc.
class AlbumPhotosView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<AlbumPhotosBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.photosTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.photosLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        // Photos use the whole width: more columns on a tablet.
        builder: (context, data) => AppPage(
          maxWidth: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: data.album.title,
                count: data.photos.length,
              ),
              Expanded(
                child: data.photos.isEmpty
                    ? AppStatusView.empty(title: l10n.photosEmptyTitle)
                    : RefreshIndicator(
                        onRefresh: bloc.refresh,
                        child: PhotoGrid(
                          photos: data.photos,
                          onTap: (photo) => PhotoRoute(
                            userId: data.album.userId,
                            albumId: data.album.id,
                            photoId: photo.id,
                          ).go(context),
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
