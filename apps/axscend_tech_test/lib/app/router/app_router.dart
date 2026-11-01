import 'package:axscend_tech_test/app/router/not_found_screen.dart';
import 'package:axscend_tech_test/app/router/routes.dart';
import 'package:go_router/go_router.dart';

/// The app's router: the typed routes, the redirect, and a "page not found"
/// screen for any address no route matches.
GoRouter createAppRouter({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  routes: $appRoutes,
  redirect: (context, state) => appRedirect(state.uri.path),
  errorBuilder: (context, state) => const NotFoundScreen(),
);

/// Where to send [path] instead, or null to stay. The only place that
/// decides this, kept pure so it can be tested directly.
String? appRedirect(String path) =>
    path == '/' ? const UsersRoute().location : null;
