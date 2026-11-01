import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/injector.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:axscend_tech_test/journeys/posts/screens/post_screen.dart';
import 'package:axscend_tech_test/journeys/posts/screens/user_posts_screen.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/models/todo_models.dart';
import 'package:axscend_tech_test/journeys/todos/screens/user_todos_screen.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/models/user_profile.dart';
import 'package:axscend_tech_test/journeys/users/screens/user_profile_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/posts_todos.dart';
import '../helpers/pump_app.dart';
import '../helpers/users.dart';

void main() {
  late MockGoRouter router;
  final user = testUser(id: 7, name: 'Leanne Graham', username: 'Bret');

  setUp(() => router = MockGoRouter());
  tearDown(getIt.reset);

  LoadState<T> loaded<T>(T data) =>
      LoadState(status: LoadStatus.success, data: data);

  group(UserProfileView, () {
    late MockUserProfileBloc bloc;
    setUp(() => bloc = MockUserProfileBloc());

    final profile = UserProfile(
      user: user,
      postCount: 10,
      albumCount: 1,
      todoCount: 20,
      doneCount: 9,
    );

    Future<void> pumpView(WidgetTester tester) async {
      when(() => bloc.state).thenReturn(loaded(profile));
      await tester.pumpApp(
        BlocProvider<UserProfileBloc>.value(
          value: bloc,
          child: const UserProfileView(),
        ),
        router: router,
        size: TestWindows.phone,
      );
    }

    testWidgets('the screen gets its bloc for the user and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<UserProfileBloc, int, void>((userId, _) {
        expect(userId, 7);
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(const UserProfileScreen(userId: 7));

      verify(() => bloc.add(const LoadRequested())).called(1);
      expect(find.text(l10n.profileLoading), findsOneWidget);
    });

    testWidgets('shows who the user is and how to reach them', (tester) async {
      await pumpView(tester);

      expect(find.text('Leanne Graham'), findsOneWidget);
      expect(find.text('@Bret'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(
        find.text(
          l10n.profileAddressLine(
            '1 Test Street',
            'Suite 1',
            'Testville',
            '12345',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Test Company Ltd'), findsOneWidget);
    });

    testWidgets('counts each thing, and opens it', (tester) async {
      await pumpView(tester);
      await tester.scrollUntilVisible(
        find.text(l10n.todosDoneCount(9, 20)),
        200,
      );

      expect(find.text(l10n.profilePostsCount(10)), findsOneWidget);
      expect(find.text(l10n.profileAlbumsCount(1)), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);

      for (final row in [
        l10n.profilePosts,
        l10n.profileAlbums,
        l10n.profileTodos,
      ]) {
        await tester.ensureVisible(find.text(row));
        await tester.pumpAndSettle();
        await tester.tap(find.text(row));
      }
      verify(() => router.go('/users/7/posts')).called(1);
      verify(() => router.go('/users/7/albums')).called(1);
      verify(() => router.go('/users/7/todos')).called(1);
    });
  });

  group(UserPostsView, () {
    late MockUserPostsBloc bloc;
    setUp(() => bloc = MockUserPostsBloc());

    Future<void> pumpView(WidgetTester tester, UserPosts data) async {
      when(() => bloc.state).thenReturn(loaded(data));
      await tester.pumpApp(
        BlocProvider<UserPostsBloc>.value(
          value: bloc,
          child: const UserPostsView(),
        ),
        router: router,
      );
    }

    testWidgets('the screen gets its bloc for the user and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<UserPostsBloc, int, void>((userId, _) {
        expect(userId, 7);
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(const UserPostsScreen(userId: 7));

      verify(() => bloc.add(const LoadRequested())).called(1);
    });

    testWidgets('lists the posts under the user, and opens one', (
      tester,
    ) async {
      await pumpView(
        tester,
        UserPosts(user: user, posts: [testPost(id: 3, userId: 7)]),
      );

      expect(find.text('Leanne Graham'), findsOneWidget);
      expect(find.text('A first post'), findsOneWidget);
      await tester.tap(find.text('A first post'));
      verify(() => router.go('/users/7/posts/3')).called(1);
    });

    testWidgets('says so when the user has no posts', (tester) async {
      await pumpView(tester, UserPosts(user: user, posts: const []));

      expect(find.text(l10n.postsEmptyTitle), findsOneWidget);
    });
  });

  group(PostView, () {
    late MockPostBloc bloc;
    setUp(() => bloc = MockPostBloc());

    Future<void> pumpView(WidgetTester tester, PostDetails data) async {
      when(() => bloc.state).thenReturn(loaded(data));
      await tester.pumpApp(
        BlocProvider<PostBloc>.value(value: bloc, child: const PostView()),
      );
    }

    testWidgets('the screen gets its bloc for the post and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<PostBloc, PostAddress, void>((address, _) {
        expect(address, (userId: 7, postId: 3));
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(const PostScreen(address: (userId: 7, postId: 3)));

      verify(() => bloc.add(const LoadRequested())).called(1);
    });

    testWidgets('shows the post, then its comments', (tester) async {
      await pumpView(
        tester,
        PostDetails(
          post: testPost(id: 3, userId: 7),
          comments: [testComment(postId: 3), testComment(id: 2, postId: 3)],
        ),
      );

      expect(find.text('A first post'), findsOneWidget);
      expect(find.text('Some words about it.'), findsOneWidget);
      expect(find.text(l10n.commentsHeader), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Nice post.'), findsNWidgets(2));
    });

    testWidgets('says so when a post has no comments', (tester) async {
      await pumpView(
        tester,
        PostDetails(post: testPost(id: 3, userId: 7), comments: const []),
      );

      expect(find.text(l10n.commentsEmptyTitle), findsOneWidget);
    });
  });

  group(UserTodosView, () {
    late MockUserTodosBloc bloc;
    setUp(() => bloc = MockUserTodosBloc());

    final todos = [
      testTodo(userId: 7, title: 'Walk the dog', completed: true),
      testTodo(id: 2, userId: 7),
      testTodo(id: 3, userId: 7, title: 'Pay rent', completed: true),
      testTodo(id: 4, userId: 7, title: 'Call mum'),
    ];

    Future<void> pumpView(WidgetTester tester, List<Todo> list) async {
      when(() => bloc.state)
          .thenReturn(loaded(UserTodos(user: user, todos: list)));
      await tester.pumpApp(
        BlocProvider<UserTodosBloc>.value(
          value: bloc,
          child: const UserTodosView(),
        ),
      );
    }

    testWidgets('the screen gets its bloc for the user and starts loading', (
      tester,
    ) async {
      getIt.registerFactoryParam<UserTodosBloc, int, void>((userId, _) {
        expect(userId, 7);
        return bloc;
      });
      when(() => bloc.state).thenReturn(const LoadState());
      await tester.pumpApp(const UserTodosScreen(userId: 7));

      verify(() => bloc.add(const LoadRequested())).called(1);
    });

    testWidgets('shows every todo, the share done and the counts', (
      tester,
    ) async {
      await pumpView(tester, todos);

      expect(find.byType(AppCheckRow), findsNWidgets(4));
      expect(find.text('50%'), findsOneWidget);
      expect(find.text(l10n.todosFilterAll(4)), findsOneWidget);
      expect(find.text(l10n.todosFilterDone(2)), findsOneWidget);
      expect(find.text(l10n.todosFilterPending(2)), findsOneWidget);
    });

    testWidgets('filters to the done, then the pending todos', (tester) async {
      await pumpView(tester, todos);

      await tester.tap(find.text(l10n.todosFilterDone(2)));
      await tester.pumpAndSettle();
      expect(find.text('Walk the dog'), findsOneWidget);
      expect(find.text('Buy milk'), findsNothing);

      await tester.tap(find.text(l10n.todosFilterPending(2)));
      await tester.pumpAndSettle();
      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Walk the dog'), findsNothing);
    });

    testWidgets('says when a filter shows nothing', (tester) async {
      await pumpView(tester, [testTodo(userId: 7, completed: true)]);

      await tester.tap(find.text(l10n.todosFilterPending(0)));
      await tester.pumpAndSettle();
      expect(find.text(l10n.todosNonePendingTitle), findsOneWidget);
    });
  });
}
