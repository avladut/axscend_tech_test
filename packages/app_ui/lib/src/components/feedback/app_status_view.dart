import 'package:app_ui/src/foundation/app_sizes.dart';
import 'package:app_ui/src/foundation/app_spacing.dart';
import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

enum _Status { loading, empty, error }

/// What a screen shows instead of its content: loading, nothing found, or
/// an error with a way to retry.
class AppStatusView extends StatelessWidget {
  /// A spinner, with an optional [title] such as "Loading users…".
  const new loading({this.title, super.key})
    : _status = _Status.loading,
      message = null,
      actionLabel = null,
      onAction = null;

  /// Nothing to show, such as no search results.
  const new empty({required String this.title, this.message, super.key})
    : _status = _Status.empty,
      actionLabel = null,
      onAction = null;

  /// Something went wrong. Offer [actionLabel] (such as "Try again") when
  /// trying again could help.
  const new error({
    required String this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : _status = _Status.error;

  final _Status _status;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final message = this.message;
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;
    return Center(
      child: SingleChildScrollView(
        padding: AppInsets.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (_status) {
              _Status.loading => const CircularProgressIndicator(),
              _Status.empty => Icon(
                Icons.search_off,
                size: AppSizes.iconLg,
                color: context.appColors.muted,
              ),
              _Status.error => Icon(
                Icons.cloud_off_outlined,
                size: AppSizes.iconLg,
                color: context.colors.error,
              ),
            },
            if (title != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: context.textStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.appColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
