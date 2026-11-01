import 'package:app_ui/src/foundation/app_radius.dart';
import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// A picture from the web, with rounded corners. Shows a quiet placeholder
/// while it loads and a broken-image icon if it can't.
class AppNetworkImage extends StatelessWidget {
  const new({
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    super.key,
  });

  final Uri url;

  /// What the picture shows, for screen readers.
  final String semanticLabel;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.borderMd,
    child: Image.network(
      url.toString(),
      fit: fit,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _Placeholder(Icons.image_outlined),
      errorBuilder: (context, error, stackTrace) =>
          const _Placeholder(Icons.broken_image_outlined),
    ),
  );
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
