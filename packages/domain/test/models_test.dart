import 'package:domain/domain.dart';
import 'package:test/test.dart';

/// Two separately built copies are equal, and changing any one field makes it
/// different. A field missing from `props` fails the second part.
void expectValueEquality<T>(T Function() build, Map<String, T> changed) {
  final a = build();
  final b = build();
  expect(identical(a, b), isFalse, reason: 'build must not return a constant');
  expect(a, equals(b));
  expect(a.hashCode, b.hashCode);
  changed.forEach((field, other) {
    expect(other, isNot(equals(a)), reason: '$field must count');
  });
}

// Builders with real JSONPlaceholder values. Each test changes one field.

Geo geo({double lat = -37.3159, double lng = 81.1496}) =>
    Geo(lat: lat, lng: lng);

Address address({
  String street = 'Kulas Light',
  String suite = 'Apt. 556',
  String city = 'Gwenborough',
  String zipcode = '92998-3874',
  Geo? location,
}) => Address(
  street: street,
  suite: suite,
  city: city,
  zipcode: zipcode,
  geo: location ?? geo(),
);

Company company({
  String name = 'Romaguera-Crona',
  String catchPhrase = 'Multi-layered client-server neural-net',
  String bs = 'harness real-time e-markets',
}) => Company(name: name, catchPhrase: catchPhrase, bs: bs);

User user({
  int id = 1,
  String name = 'Leanne Graham',
  String username = 'Bret',
  String email = 'Sincere@april.biz',
  String phone = '1-770-736-8031 x56442',
  String website = 'hildegard.org',
  Address? home,
  Company? employer,
}) => User(
  id: id,
  name: name,
  username: username,
  email: email,
  phone: phone,
  website: website,
  address: home ?? address(),
  company: employer ?? company(),
);

Post post({
  int id = 1,
  int userId = 1,
  String title = 'sunt aut facere',
  String body = 'quia et suscipit',
}) => Post(id: id, userId: userId, title: title, body: body);

Comment comment({
  int id = 1,
  int postId = 1,
  String name = 'id labore ex et quam laborum',
  String email = 'Eliseo@gardner.biz',
  String body = 'laudantium enim quasi',
}) => Comment(id: id, postId: postId, name: name, email: email, body: body);

Album album({int id = 1, int userId = 1, String title = 'quidem molestiae'}) =>
    Album(id: id, userId: userId, title: title);

Photo photo({
  int id = 1,
  int albumId = 1,
  String title = 'accusamus beatae',
  String url = 'https://picsum.photos/id/1/600',
  String thumbnailUrl = 'https://picsum.photos/id/1/150',
}) => Photo(
  id: id,
  albumId: albumId,
  title: title,
  url: Uri.parse(url),
  thumbnailUrl: Uri.parse(thumbnailUrl),
);

Todo todo({
  int id = 1,
  int userId = 1,
  String title = 'delectus aut autem',
  bool completed = false,
}) => Todo(id: id, userId: userId, title: title, completed: completed);

void main() {
  test('Geo', () {
    expectValueEquality(geo, {'lat': geo(lat: 0), 'lng': geo(lng: 0)});
  });

  test('Address', () {
    expectValueEquality(address, {
      'street': address(street: 'Victor Plains'),
      'suite': address(suite: 'Suite 879'),
      'city': address(city: 'Wisokyburgh'),
      'zipcode': address(zipcode: '90566-7771'),
      'geo': address(location: geo(lat: -43.9509)),
    });
  });

  test('Company', () {
    expectValueEquality(company, {
      'name': company(name: 'Deckow-Crist'),
      'catchPhrase': company(catchPhrase: 'Proactive didactic contingency'),
      'bs': company(bs: 'synergize scalable supply-chains'),
    });
  });

  group('User', () {
    test('compares by value', () {
      expectValueEquality(user, {
        'id': user(id: 2),
        'name': user(name: 'Ervin Howell'),
        'username': user(username: 'Antonette'),
        'email': user(email: 'Shanna@melissa.tv'),
        'phone': user(phone: '010-692-6593 x09125'),
        'website': user(website: 'anastasia.net'),
        'address': user(home: address(city: 'Wisokyburgh')),
        'company': user(employer: company(name: 'Deckow-Crist')),
      });
    });

    test('compares nested values deeply', () {
      // A change two levels down still makes the users different.
      expect(user(home: address(location: geo(lng: 0))), isNot(equals(user())));
    });
  });

  test('Post', () {
    expectValueEquality(post, {
      'id': post(id: 2),
      'userId': post(userId: 2),
      'title': post(title: 'qui est esse'),
      'body': post(body: 'est rerum tempore'),
    });
  });

  test('Comment', () {
    expectValueEquality(comment, {
      'id': comment(id: 2),
      'postId': comment(postId: 2),
      'name': comment(name: 'quo vero reiciendis'),
      'email': comment(email: 'Jayne_Kuhic@sydney.com'),
      'body': comment(body: 'est natus enim'),
    });
  });

  test('Album', () {
    expectValueEquality(album, {
      'id': album(id: 2),
      'userId': album(userId: 2),
      'title': album(title: 'sunt qui excepturi'),
    });
  });

  test('Photo', () {
    expectValueEquality(photo, {
      'id': photo(id: 2),
      'albumId': photo(albumId: 2),
      'title': photo(title: 'reprehenderit est'),
      'url': photo(url: 'https://picsum.photos/id/2/600'),
      'thumbnailUrl': photo(thumbnailUrl: 'https://picsum.photos/id/2/150'),
    });
  });

  test('Todo', () {
    expectValueEquality(todo, {
      'id': todo(id: 2),
      'userId': todo(userId: 2),
      'title': todo(title: 'quis ut nam facilis'),
      'completed': todo(completed: true),
    });
  });
}
