import 'package:axscend_tech_test/app/app.dart';
import 'package:axscend_tech_test/app/router/app_router.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:axscend_tech_test/journeys/users/screens/users_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/users.dart';

void main() {
  group('appRedirect', () {
    test('sends the root to the users', () {
      expect(appRedirect('/'), '/users');
    });

    test('leaves every other address alone', () {
      expect(appRedirect('/users'), isNull);
      expect(appRedirect('/nowhere'), isNull);
    });
  });

  group('createAppRouter', () {
    setUp(() {
      final bloc = MockUsersBloc();
      // Loaded, so no spinner keeps pumpAndSettle waiting.
      when(() => bloc.state).thenReturn(
        UsersState(status: UsersStatus.success, window: windowOf(const [])),
      );
      getIt.registerFactory<UsersBloc>(() => bloc);
    });
    tearDown(getIt.reset);

    testWidgets('opens on the users', (tester) async {
      await tester.pumpWidget(App(router: createAppRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(UsersScreen), findsOneWidget);
    });

    testWidgets('shows "page not found" for an unknown address, with a way '
        'back', (tester) async {
      await tester.pumpWidget(
        App(router: createAppRouter(initialLocation: '/nowhere')),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.notFoundTitle), findsOneWidget);
      await tester.tap(find.text(l10n.notFoundAction));
      await tester.pumpAndSettle();
      expect(find.byType(UsersScreen), findsOneWidget);
    });
  });
}
