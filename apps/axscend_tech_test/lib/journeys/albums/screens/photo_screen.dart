import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/load_state_view.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/albums/blocs/photo_bloc.dart';
import 'package:axscend_tech_test/journeys/albums/models/album_addresses.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One photo at full size, with its title. Provides a fresh [PhotoBloc] and
/// starts loading.
class PhotoScreen extends StatelessWidget {
  const new({required this.address, super.key});

  final PhotoAddress address;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<PhotoBloc>(param1: address)..add(const LoadRequested()),
    child: const PhotoView(),
  );
}

/// Renders the [PhotoBloc]'s state. Tests pump it with a mock bloc.
class PhotoView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<PhotoBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.photoTitle)),
      body: LoadStateView(
        state: bloc.state,
        loadingTitle: l10n.photoLoading,
        onRetry: () => bloc.add(const LoadRequested(refresh: true)),
        // The photo shrinks to fit the screen, so the title always shows.
        // The square box keeps the layout still while it loads; contain
        // shows the whole photo, whatever its shape.
        builder: (context, photo) => AppPage(
          child: Column(
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(
                    url: photo.url,
                    semanticLabel: photo.title,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(photo.title, style: context.textStyles.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
