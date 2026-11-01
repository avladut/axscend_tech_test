import 'package:app_ui/src/foundation/app_radius.dart';
import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/images/app_image_cache.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A picture from the web, with rounded corners. Shows a quiet placeholder
/// while it loads and a broken-image icon if it can't.
///
/// Pictures are kept on the device ([AppImageCache]), so one seen before
/// shows straight away, even offline. Each is decoded at the size it's shown,
/// not its full size.
class AppNetworkImage extends StatelessWidget {
  const new({
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.onTap,
    super.key,
  });

  final Uri url;

  /// What the picture shows, for screen readers.
  final String semanticLabel;

  final BoxFit fit;

  /// Makes the picture a button, with the usual ripple.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return Semantics(
      label: semanticLabel,
      image: true,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.borderMd,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = CachedNetworkImage(
              imageUrl: url.toString(),
              cacheManager: AppImageCacheScope.of(context),
              fit: fit,
              memCacheWidth: constraints.hasBoundedWidth
                  ? (constraints.maxWidth *
                            MediaQuery.devicePixelRatioOf(context))
                        .round()
                  : null,
              placeholder: (_, _) => const _Placeholder(Icons.image_outlined),
              errorWidget: (_, _, _) =>
                  const _Placeholder(Icons.broken_image_outlined),
            );
            if (onTap == null) return image;
            // passthrough keeps the box's size for the picture: a plain
            // Stack would loosen it, and the picture would shrink to its
            // own size in a corner of a bigger tile.
            return Stack(
              fit: StackFit.passthrough,
              children: [
                image,
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onTap),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const new(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceContainerHighest,
    child: Center(
      child: Icon(icon, size: AppSizes.iconLg, color: context.appColors.muted),
    ),
  );
}
