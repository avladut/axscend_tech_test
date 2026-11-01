import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'models_test.dart' show expectValueEquality;

// Builders with parameters, so each call makes a new (non-const) instance.

PageRequest pageRequest({int index = 1, int size = 20}) =>
    PageRequest(index: index, size: size);

ResultPage<int> resultPage({List<int> items = const [1, 2], int total = 10}) =>
    ResultPage(items: items, total: total);

UserQuery userQuery({String text = 'a', UserSort sort = UserSort.city}) =>
    UserQuery(text: text, sort: sort);

void main() {
  group(PageRequest, () {
    test('starts each page after the ones before it', () {
      expect(const PageRequest(index: 0, size: 20).offset, 0);
      expect(const PageRequest(index: 3, size: 20).offset, 60);
    });

    test('is a value', () {
      expectValueEquality(pageRequest, {
        'index': pageRequest(index: 2),
        'size': pageRequest(size: 10),
      });
    });
  });

  group(ResultPage, () {
    test('is a value', () {
      expectValueEquality(resultPage, {
        'items': resultPage(items: [1]),
        'total': resultPage(total: 11),
      });
    });
  });

  group(UserQuery, () {
    test('lists everyone by name by default', () {
      const query = UserQuery();
      expect(query.sort, UserSort.nameAscending);
      expect(query.isSearching, isFalse);
    });

    test('searches for the text without the spaces around it', () {
      const query = UserQuery(text: '  rom ');
      expect(query.search, 'rom');
      expect(query.isSearching, isTrue);
      expect(const UserQuery(text: '   ').isSearching, isFalse);
    });

    test('copyWith changes only what is passed', () {
      const query = UserQuery(text: 'a');
      expect(
        query.copyWith(sort: UserSort.city),
        const UserQuery(text: 'a', sort: UserSort.city),
      );
      expect(query.copyWith(text: 'b'), const UserQuery(text: 'b'));
    });

    test('is a value', () {
      expectValueEquality(userQuery, {
        'text': userQuery(text: 'b'),
        'sort': userQuery(sort: UserSort.company),
      });
    });
  });
}
