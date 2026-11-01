import 'package:axscend_tech_test/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:axscend_tech_test/l10n/gen/app_localizations.dart';

/// How widgets read the translations: `context.l10n.usersTitle`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
