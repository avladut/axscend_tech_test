import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/post_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/blocs/user_posts_bloc.dart';
import 'package:axscend_tech_test/journeys/posts/models/post_models.dart';
import 'package:axscend_tech_test/journeys/todos/blocs/user_todos_bloc.dart';
import 'package:axscend_tech_test/journeys/todos/models/todo_models.dart';
import 'package:axscend_tech_test/journeys/users/blocs/user_profile_bloc.dart';
import 'package:axscend_tech_test/journeys/users/models/user_profile.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository;

class MockTodoRepository extends Mock implements TodoRepository;

class MockUserProfileBloc
    extends MockBloc<LoadRequested, LoadState<UserProfile>>
    implements UserProfileBloc;

class MockUserPostsBloc extends MockBloc<LoadRequested, LoadState<UserPosts>>
    implements UserPostsBloc;

class MockPostBloc extends MockBloc<LoadRequested, LoadState<PostDetails>>
    implements PostBloc;

class MockUserTodosBloc extends MockBloc<LoadRequested, LoadState<UserTodos>>
    implements UserTodosBloc;

/// A made-up post by user [userId].
Post testPost({
  int id = 1,
  int userId = 1,
  String title = 'A first post',
  String body = 'Some words about it.',
}) => Post(id: id, userId: userId, title: title, body: body);

/// A made-up comment on post [postId].
Comment testComment({
  int id = 1,
  int postId = 1,
  String name = 'A reader',
  String body = 'Nice post.',
}) => Comment(
  id: id,
  postId: postId,
  name: name,
  email: 'reader@example.com',
  body: body,
);

/// A made-up todo of user [userId].
Todo testTodo({
  int id = 1,
  int userId = 1,
  String title = 'Buy milk',
  bool completed = false,
}) => Todo(id: id, userId: userId, title: title, completed: completed);
