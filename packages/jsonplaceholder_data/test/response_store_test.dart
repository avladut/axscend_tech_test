import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';
import 'package:test/test.dart';

void main() {
  group(InMemoryResponseStore, () {
    test('gives back what it saved', () async {
      final store = InMemoryResponseStore();
      await store.write('/users', ['a']);

      expect(await store.read('/users'), ['a']);
      expect(await store.read('/todos'), isNull);
    });

    test('keeps 50 answers unless told otherwise', () {
      expect(InMemoryResponseStore().maxEntries, 50);
    });

    test('forgets the answer used longest ago when full', () async {
      final store = InMemoryResponseStore(maxEntries: 2);
      await store.write('a', 1);
      await store.write('b', 2);
      await store.read('a'); // Now "b" is the one used longest ago.
      await store.write('c', 3);

      expect(store.length, 2);
      expect(await store.read('a'), 1);
      expect(await store.read('b'), isNull);
      expect(await store.read('c'), 3);
    });

    test('replacing an answer does not take more room', () async {
      final store = InMemoryResponseStore(maxEntries: 2);
      await store.write('a', 1);
      await store.write('b', 2);
      await store.write('a', 10);

      expect(store.length, 2);
      expect(await store.read('a'), 10);
      expect(await store.read('b'), 2);
    });
  });
}
