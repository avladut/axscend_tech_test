import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/brand.dart';
import 'package:axscend_tech_test/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The root widget: the brand's light and dark themes, the translations and
/// the [router].
class App extends StatelessWidget {
  const new({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: appBrand.name,
    theme: AppTheme.light(appBrand),
    darkTheme: AppTheme.dark(appBrand),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
    debugShowCheckedModeBanner: false,
  );
}
