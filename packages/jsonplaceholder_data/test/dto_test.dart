import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/album_dto.dart';
import 'package:jsonplaceholder_data/src/dto/comment_dto.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/photo_dto.dart';
import 'package:jsonplaceholder_data/src/dto/post_dto.dart';
import 'package:jsonplaceholder_data/src/dto/todo_dto.dart';
import 'package:jsonplaceholder_data/src/dto/user_dto.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

final Matcher throwsUnexpectedData = throwsA(isA<UnexpectedDataFailure>());

void main() {
  group('UserDto', () {
    User parse(Object? json) => UserDto.fromJson(json).toDomain();

    test('maps a real user, nested objects and coordinates included', () {
      expect(parse(fixtureItem('users')), leanne);
      expect(parse(fixtureItem('users', 1)).name, 'Ervin Howell');
    });

    test('rejects a missing field', () {
      expect(
        () => parse(fixtureItem('users')..remove('email')),
        throwsUnexpectedData,
      );
    });

    test('rejects a wrongly typed field', () {
      expect(
        () => parse(fixtureItem('users')..['id'] = '1'),
        throwsUnexpectedData,
      );
    });

    test('rejects a broken nested object', () {
      final user = fixtureItem('users');
      (user['address']! as Map<String, Object?>).remove('city');
      expect(() => parse(user), throwsUnexpectedData);
    });

    test('rejects coordinates that are not numbers', () {
      final user = fixtureItem('users');
      final address = user['address']! as Map<String, Object?>;
      (address['geo']! as Map<String, Object?>)['lat'] = 'north';
      expect(() => parse(user), throwsUnexpectedData);
    });

    test('ignores fields it does not know', () {
      expect(parse(fixtureItem('users')..['nickname'] = 'Lea'), leanne);
    });
  });

  test('PostDto maps a real post', () {
    final post = PostDto.fromJson(fixtureItem('posts')).toDomain();
    expect((post.id, post.userId), (1, 1));
    expect(post.title, startsWith('sunt aut facere'));
    expect(post.body, startsWith('quia et suscipit'));
    expect(
      () => PostDto.fromJson(fixtureItem('posts')..remove('body')),
      throwsUnexpectedData,
    );
  });

  test('CommentDto maps a real comment', () {
    final comment = CommentDto.fromJson(fixtureItem('comments')).toDomain();
    expect((comment.id, comment.postId), (1, 1));
    expect(comment.name, 'id labore ex et quam laborum');
    expect(comment.email, 'Eliseo@gardner.biz');
    expect(
      () => CommentDto.fromJson(fixtureItem('comments')..['postId'] = null),
      throwsUnexpectedData,
    );
  });

  test('AlbumDto maps a real album', () {
    expect(
      AlbumDto.fromJson(fixtureItem('albums')).toDomain(),
      const Album(id: 1, userId: 1, title: 'quidem molestiae enim'),
    );
    expect(
      () => AlbumDto.fromJson(fixtureItem('albums')..['title'] = 7),
      throwsUnexpectedData,
    );
  });

  group('PhotoDto', () {
    test('maps a real photo, with its links as Uris', () {
      final photo = PhotoDto.fromJson(fixtureItem('photos')).toDomain();
      expect((photo.id, photo.albumId), (1, 1));
      expect(photo.url, Uri.parse('https://picsum.photos/seed/1/600'));
      expect(photo.thumbnailUrl, Uri.parse('https://picsum.photos/seed/1/150'));
    });

    test('rejects a link that is not absolute', () {
      expect(
        () =>
            PhotoDto.fromJson(fixtureItem('photos')..['url'] = 'not a link')
                .toDomain(),
        throwsUnexpectedData,
      );
    });
  });

  test('TodoDto maps real todos, done and not done', () {
    final todos = [
      for (final json in fixture('todos')) TodoDto.fromJson(json).toDomain(),
    ];
    expect(todos.map((todo) => todo.completed), [false, true]);
    expect(todos.first.title, 'delectus aut autem');
    expect(
      () => TodoDto.fromJson(fixtureItem('todos')..['completed'] = 'yes'),
      throwsUnexpectedData,
    );
  });

  group('parseList', () {
    test('parses every item', () {
      expect(
        parseList(fixture('users'), 'user', UserDto.fromJson),
        hasLength(2),
      );
    });

    test('rejects an answer that is not a list', () {
      expect(
        () => parseList(fixtureItem('users'), 'user', UserDto.fromJson),
        throwsA(
          isA<UnexpectedDataFailure>().having(
            (failure) => failure.detail,
            'detail',
            startsWith('Not a valid list of users'),
          ),
        ),
      );
    });

    test('rejects a list with an item that is not an object', () {
      expect(
        () => parseList([fixtureItem('users'), 42], 'user', UserDto.fromJson),
        throwsUnexpectedData,
      );
    });

    test('keeps the logged detail short', () {
      final huge = List.filled(500, 'x').join();
      expect(
        () => UserDto.fromJson(huge),
        throwsA(
          isA<UnexpectedDataFailure>().having(
            (failure) => failure.detail!.length,
            'detail length',
            lessThan(250),
          ),
        ),
      );
    });
  });
}
