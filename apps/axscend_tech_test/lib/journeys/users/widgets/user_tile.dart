import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';

/// One user in a list: their initials, name, username and company.
class UserTile extends StatelessWidget {
  const new({required this.user, this.onTap, super.key});

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppListTile(
    leading: AppAvatar(name: user.name),
    title: user.name,
    subtitle: context.l10n.usersTileSubtitle(user.username, user.company.name),
    onTap: onTap,
  );
}
