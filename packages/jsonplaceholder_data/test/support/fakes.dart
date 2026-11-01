import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/jsonplaceholder_data.dart';

/// A fixture from `test/fixtures/`: real API answers, a few items each.
/// Decoded fresh on every call, so a test can change it freely.
List<Object?> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as List<Object?>;

/// One item of a fixture, as a map a test can break.
Map<String, Object?> fixtureItem(String name, [int index = 0]) =>
    fixture(name)[index]! as Map<String, Object?>;

/// Answers from a map of path → JSON, and records every call.
class FakeJsonClient implements JsonClient {
  new([Map<String, Object?> answers = const {}]) : answers = {...answers};

  final Map<String, Object?> answers;
  final calls = <({String path, bool refresh})>[];

  /// When set, every call throws it instead of answering.
  DataFailure? failure;

  @override
  Future<Object?> get(String path, {bool refresh = false}) async {
    calls.add((path: path, refresh: refresh));
    if (failure case final failure?) throw failure;
    if (!answers.containsKey(path)) throw NotFoundFailure(detail: path);
    return answers[path];
  }
}

/// User 1 from `users.json`, as the domain sees it.
const leanne = User(
  id: 1,
  name: 'Leanne Graham',
  username: 'Bret',
  email: 'Sincere@april.biz',
  phone: '1-770-736-8031 x56442',
  website: 'hildegard.org',
  address: Address(
    street: 'Kulas Light',
    suite: 'Apt. 556',
    city: 'Gwenborough',
    zipcode: '92998-3874',
    geo: Geo(lat: -37.3159, lng: 81.1496),
  ),
  company: Company(
    name: 'Romaguera-Crona',
    catchPhrase: 'Multi-layered client-server neural-net',
    bs: 'harness real-time e-markets',
  ),
);
