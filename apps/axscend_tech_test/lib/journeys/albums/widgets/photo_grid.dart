import 'package:app_ui/app_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Photo thumbnails in square tiles, as many columns as fit at least
/// `AppSizes.gridTileMinWidth` wide each: two on a phone, more on a tablet.
/// Only the tiles on screen are built.
class PhotoGrid extends StatelessWidget {
  const new({required this.photos, required this.onTap, super.key});

  final List<Photo> photos;
  final ValueChanged<Photo> onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => GridView.builder(
      // Pull-to-refresh works even when the grid is short.
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (constraints.maxWidth / AppSizes.gridTileMinWidth)
            .floor()
            .clamp(2, 12),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return AppNetworkImage(
          url: photo.thumbnailUrl,
          semanticLabel: photo.title,
          onTap: () => onTap(photo),
        );
      },
    ),
  );
}
