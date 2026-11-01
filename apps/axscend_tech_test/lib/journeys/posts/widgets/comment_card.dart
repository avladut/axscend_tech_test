import 'package:app_ui/app_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// One comment: who wrote it, their email, and what they said.
class CommentCard extends StatelessWidget {
  const new({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(comment.name, style: context.textStyles.titleSmall),
        Text(
          comment.email,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.appColors.muted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(comment.body, style: context.textStyles.bodyMedium),
      ],
    ),
  );
}
