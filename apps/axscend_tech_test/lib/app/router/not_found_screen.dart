import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Shown for an address no route matches, such as an old or mistyped link.
class NotFoundScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: AppStatusView.error(
          title: l10n.notFoundTitle,
          message: l10n.notFoundMessage,
          actionLabel: l10n.notFoundAction,
          onAction: () => const UsersRoute().go(context),
        ),
      ),
    );
  }
}
