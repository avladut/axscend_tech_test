import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/failures/data_failure_text.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';

/// A screen's content when its data couldn't be loaded: what went wrong, in
/// the user's language, and "Try again" when that could help.
class DataFailureView extends StatelessWidget {
  const new({required this.failure, required this.onRetry, super.key});

  final DataFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = failure.describe(l10n);
    final canRetry = failure.canRetry;
    return AppStatusView.error(
      title: text.title,
      message: text.message,
      actionLabel: canRetry ? l10n.tryAgain : null,
      onAction: canRetry ? onRetry : null,
    );
  }
}
