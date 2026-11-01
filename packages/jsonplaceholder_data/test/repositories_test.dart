import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  late FakeJsonClient client;

  setUp(() {
    client = FakeJsonClient({
      '/users': fixture('users'),
      '/users/1': fixtureItem('users'),
      '/posts': fixture('posts'),
      '/users/1/posts': fixture('posts'),
      '/posts/1': fixtureItem('posts'),
      '/posts/1/comments': fixture('comments'),
      '/albums': fixture('albums'),
      '/users/1/albums': fixture('albums'),
      '/albums/1': fixtureItem('albums'),
      '/albums/1/photos': fixture('photos'),
      '/todos': fixture('todos'),
      '/users/1/todos': fixture('todos'),
    });
  });

  List<String> paths() => [for (final call in client.calls) call.path];

  group(JsonPlaceholderUserRepository, () {
    late UserRepository users;
    setUp(() => users = JsonPlaceholderUserRepository(client));

    test('reads all users', () async {
      final result = await users.getUsers();

      expect(result, hasLength(2));
      expect(result.first, leanne);
      expect(paths(), ['/users']);
    });

    test('reads one user', () async {
      expect(await users.getUser(1), leanne);
      expect(paths(), ['/users/1']);
    });

    test('passes refresh on', () async {
      await users.getUsers(refresh: true);
      await users.getUser(1, refresh: true);

      expect(client.calls.every((call) => call.refresh), isTrue);
    });

    test('lets the failure through', () async {
      client.failure = const OfflineFailure();

      await expectLater(users.getUsers(), throwsA(isA<OfflineFailure>()));
    });

    test('rejects an answer of the wrong shape', () async {
      client.answers['/users'] = fixtureItem('users');

      await expectLater(
        users.getUsers(),
        throwsA(isA<UnexpectedDataFailure>()),
      );
    });
  });

  group(JsonPlaceholderPostRepository, () {
    late PostRepository posts;
    setUp(() => posts = JsonPlaceholderPostRepository(client));

    test("reads everyone's posts, or one user's", () async {
      expect(await posts.getPosts(), hasLength(2));
      expect(
        (await posts.getPosts(userId: 1)).map((post) => post.userId),
        everyElement(1),
      );
      expect(paths(), ['/posts', '/users/1/posts']);
    });

    test('reads one post and its comments', () async {
      expect((await posts.getPost(1)).id, 1);
      final comments = await posts.getComments(1);

      expect(comments.map((comment) => comment.postId), [1, 1]);
      expect(paths(), ['/posts/1', '/posts/1/comments']);
    });

    test('passes refresh on', () async {
      await posts.getPosts(userId: 1, refresh: true);
      await posts.getPost(1, refresh: true);
      await posts.getComments(1, refresh: true);

      expect(client.calls.every((call) => call.refresh), isTrue);
    });
  });

  group(JsonPlaceholderAlbumRepository, () {
    late AlbumRepository albums;
    setUp(() => albums = JsonPlaceholderAlbumRepository(client));

    test("reads everyone's albums, or one user's", () async {
      expect(await albums.getAlbums(), hasLength(2));
      expect(await albums.getAlbums(userId: 1), hasLength(2));
      expect(paths(), ['/albums', '/users/1/albums']);
    });

    test('reads one album and its photos', () async {
      expect(
        await albums.getAlbum(1),
        const Album(id: 1, userId: 1, title: 'quidem molestiae enim'),
      );
      final photos = await albums.getPhotos(1);

      expect(photos.map((photo) => photo.albumId), [1, 1]);
      expect(photos.first.thumbnailUrl.host, 'picsum.photos');
      expect(paths(), ['/albums/1', '/albums/1/photos']);
    });

    test('passes refresh on', () async {
      await albums.getAlbums(refresh: true);
      await albums.getAlbum(1, refresh: true);
      await albums.getPhotos(1, refresh: true);

      expect(client.calls.every((call) => call.refresh), isTrue);
    });
  });

  group(JsonPlaceholderTodoRepository, () {
    late TodoRepository todos;
    setUp(() => todos = JsonPlaceholderTodoRepository(client));

    test("reads everyone's todos, or one user's", () async {
      expect(await todos.getTodos(), hasLength(2));
      final mine = await todos.getTodos(userId: 1, refresh: true);

      expect(mine.map((todo) => todo.completed), [false, true]);
      expect(client.calls, [
        (path: '/todos', refresh: false),
        (path: '/users/1/todos', refresh: true),
      ]);
    });
  });
}
