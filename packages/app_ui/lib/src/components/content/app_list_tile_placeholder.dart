import 'package:app_ui/src/components/content/app_avatar.dart';
import 'package:app_ui/src/foundation/app_radius.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Stands in for an `AppListTile` with an avatar and a subtitle while its
/// data loads: a circle and two bars where the initials and text will be.
///
/// Still, with no shimmer: the loading spinner is the only endless
/// animation. Give it a [semanticLabel] such as "Loading user", or screen
/// readers skip it.
class AppListTilePlaceholder extends StatelessWidget {
  const new({this.semanticLabel, super.key});

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fill = context.colors.surfaceContainerHighest;
    final tile = ExcludeSemantics(
      child: ListTile(
        leading: Container(
          width: AppAvatarSize.md.diameter,
          height: AppAvatarSize.md.diameter,
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        ),
        title: _Bar(color: fill, widthFactor: 0.6),
        subtitle: _Bar(color: fill, widthFactor: 0.4),
      ),
    );
    final label = semanticLabel;
    return label == null ? tile : Semantics(label: label, child: tile);
  }
}

/// A rounded bar one line of text tall. The line is an invisible space, so
/// the bar takes the same height as real text at any text size, and the row
/// doesn't jump when the data arrives.
class _Bar extends StatelessWidget {
  const new({required this.color, required this.widthFactor});

  final Color color;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: AlignmentDirectional.centerStart,
    widthFactor: widthFactor,
    child: Stack(
      children: [
        const Text('\u00A0'),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: AppRadius.borderSm,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
