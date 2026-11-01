import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('configureDependencies', () {
    setUp(configureDependencies);
    tearDown(getIt.reset);

    test('offers each repository contract, one shared instance each', () {
      expect(getIt<UserRepository>(), same(getIt<UserRepository>()));
      expect(getIt<PostRepository>(), same(getIt<PostRepository>()));
      expect(getIt<AlbumRepository>(), same(getIt<AlbumRepository>()));
      expect(getIt<TodoRepository>(), same(getIt<TodoRepository>()));
    });

    test('makes a fresh UsersBloc for every screen', () async {
      final first = getIt<UsersBloc>();
      final second = getIt<UsersBloc>();
      expect(first, isNot(same(second)));
      await Future.wait([first.close(), second.close()]);
    });
  });
}
