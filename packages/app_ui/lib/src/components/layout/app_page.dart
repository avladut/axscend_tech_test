import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:flutter/material.dart';

/// A page body: centred, never wider than [maxWidth], with page padding.
///
/// Keeps text-heavy pages readable on tablets. [child] decides whether it
/// scrolls.
class AppPage extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = AppSizes.maxContentWidth,
    this.padding = AppInsets.page,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}
