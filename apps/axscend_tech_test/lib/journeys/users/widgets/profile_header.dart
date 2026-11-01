import 'package:app_ui/app_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// The top of a profile: the user's initials, name and username.
class ProfileHeader extends StatelessWidget {
  const new({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppAvatar(name: user.name, size: AppAvatarSize.lg),
      const SizedBox(height: AppSpacing.md),
      Text(
        user.name,
        style: context.textStyles.titleLarge,
        textAlign: TextAlign.center,
      ),
      Text(
        '@${user.username}',
        style: context.textStyles.bodyMedium?.copyWith(
          color: context.appColors.muted,
        ),
      ),
    ],
  );
}
