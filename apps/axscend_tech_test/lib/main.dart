import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/app/app.dart';
import 'package:axscend_tech_test/app/router/app_router.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppImageCache.limitMemory();
  configureDependencies();
  runApp(App(router: createAppRouter()));
}
