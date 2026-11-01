import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:flutter/material.dart';

/// A surface for one item, such as a post or a comment. Tappable when
/// [onTap] is set.
class AppCard extends StatelessWidget {
  const new({
    required this.child,
    this.onTap,
    this.padding = AppInsets.card,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}
