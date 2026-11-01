import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

enum AppAvatarSize {
  sm(AppSizes.avatarSm),
  md(AppSizes.avatarMd),
  lg(AppSizes.avatarLg);

  new(this.diameter);

  final double diameter;
}

/// A person's initials in a circle. The colour is picked from the name, so
/// the same person always gets the same one.
///
/// Decorative: screen readers skip it, because the name is always shown next
/// to it.
class AppAvatar extends StatelessWidget {
  const new({required this.name, this.size = AppAvatarSize.md, super.key});

  final String name;
  final AppAvatarSize size;

  /// The first letters of the first and last words, skipping titles such as
  /// "Mrs.". `?` when there are none.
  static String initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !word.endsWith('.'))
        .toList();
    if (words.isEmpty) return '?';
    final first = words.first.characters.first;
    final last = words.length > 1 ? words.last.characters.first : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pairs = [
      (colors.primaryContainer, colors.onPrimaryContainer),
      (colors.secondaryContainer, colors.onSecondaryContainer),
      (colors.tertiaryContainer, colors.onTertiaryContainer),
    ];
    final (background, foreground) =
        pairs[name.codeUnits.fold(0, (sum, unit) => sum + unit) % pairs.length];
    final style = size == AppAvatarSize.lg
        ? context.textStyles.headlineSmall
        : context.textStyles.labelLarge;

    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size.diameter / 2,
        backgroundColor: background,
        foregroundColor: foreground,
        child: Text(
          initialsOf(name),
          style: style?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
