import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/models/todo_models.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/models/user_profile.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/albums.dart';
import '../helpers/posts_todos.dart';
import '../helpers/users.dart';

void main() {
  late MockUserRepository users;
  late MockPostRepository posts;
  late MockAlbumRepository albums;
  late MockTodoRepository todos;
  final user = testUser(id: 7);
  final userPosts = [testPost(userId: 7), testPost(id: 2, userId: 7)];
  final userTodos = [
    testTodo(userId: 7, completed: true),
    testTodo(id: 2, userId: 7),
    testTodo(id: 3, userId: 7, completed: true),
  ];

  setUp(() {
    users = MockUserRepository();
    posts = MockPostRepository();
    albums = MockAlbumRepository();
    todos = MockTodoRepository();
    when(() => users.getUser(7)).thenAnswer((_) async => user);
    when(() => posts.getPosts(userId: 7)).thenAnswer((_) async => userPosts);
    when(() => albums.getAlbums(userId: 7))
        .thenAnswer((_) async => [testAlbum(userId: 7)]);
    when(() => todos.getTodos(userId: 7)).thenAnswer((_) async => userTodos);
  });

  /// Loads [bloc] once and gives back where it ended.
  Future<LoadState<T>> loaded<T>(LoadBloc<T> bloc) async {
    bloc.add(const LoadRequested());
    final state = await bloc.stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
    );
    await bloc.close();
    return state;
  }

  test('UserProfileBloc counts the posts, albums and todos', () async {
    final state = await loaded(
      UserProfileBloc(
        userId: 7,
        users: users,
        posts: posts,
        albums: albums,
        todos: todos,
      ),
    );

    expect(
      state.data,
      UserProfile(
        user: user,
        postCount: 2,
        albumCount: 1,
        todoCount: 3,
        doneCount: 2,
      ),
    );
    expect(state.data!.progress, closeTo(2 / 3, 0.001));
  });

  test('UserProfileBloc fails when any part fails', () async {
    when(() => todos.getTodos(userId: 7))
        .thenAnswer((_) async => throw const OfflineFailure());

    final state = await loaded(
      UserProfileBloc(
        userId: 7,
        users: users,
        posts: posts,
        albums: albums,
        todos: todos,
      ),
    );

    expect(state.failure, isA<OfflineFailure>());
  });

  test('UserPostsBloc loads the user and their posts', () async {
    final state = await loaded(
      UserPostsBloc(userId: 7, users: users, posts: posts),
    );

    expect(state.data, UserPosts(user: user, posts: userPosts));
  });

  group(PostBloc, () {
    final comments = [testComment(postId: 3)];

    setUp(() {
      when(() => posts.getPost(3))
          .thenAnswer((_) async => testPost(id: 3, userId: 7));
      when(() => posts.getComments(3)).thenAnswer((_) async => comments);
    });

    test('loads the post and its comments', () async {
      final state = await loaded(
        PostBloc(address: (userId: 7, postId: 3), posts: posts),
      );

      expect(
        state.data,
        PostDetails(post: testPost(id: 3, userId: 7), comments: comments),
      );
    });

    test("treats another user's post as not found", () async {
      final state = await loaded(
        PostBloc(address: (userId: 8, postId: 3), posts: posts),
      );

      expect(state.failure, isA<NotFoundFailure>());
    });
  });

  test('UserTodosBloc loads the user and their todos', () async {
    final state = await loaded(
      UserTodosBloc(userId: 7, users: users, todos: todos),
    );

    expect(state.data, UserTodos(user: user, todos: userTodos));
  });

  group(TodoFilter, () {
    test('picks all, the done or the pending todos, in order', () {
      expect(TodoFilter.all.apply(userTodos).map((t) => t.id), [1, 2, 3]);
      expect(TodoFilter.done.apply(userTodos).map((t) => t.id), [1, 3]);
      expect(TodoFilter.pending.apply(userTodos).map((t) => t.id), [2]);
    });

    test('progress is the share done, and 0 with no todos', () {
      expect(UserTodos(user: user, todos: userTodos).doneCount, 2);
      expect(UserTodos(user: user, todos: const []).progress, 0);
      expect(
        UserProfile(
          user: user,
          postCount: 0,
          albumCount: 0,
          todoCount: 0,
          doneCount: 0,
        ).progress,
        0,
      );
    });
  });
}
