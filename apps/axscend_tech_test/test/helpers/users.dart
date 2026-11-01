import 'package:axscend_tech_test/common/paging/paged_window.dart';
import 'package:axscend_tech_test/journeys/users/blocs/users_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository;

class MockUsersBloc extends MockBloc<UsersEvent, UsersState>
    implements UsersBloc;

/// Lets mocktail's `any()` stand in for these arguments.
void registerUserFallbacks() {
  registerFallbackValue(const PageRequest(index: 0, size: 1));
  registerFallbackValue(const UserQuery());
}

/// A made-up user. Only what a test cares about needs to be passed.
User testUser({
  int id = 1,
  String name = 'Test Person',
  String username = 'tester',
  String email = 'test@example.com',
  String company = 'Test Company Ltd',
  String city = 'Testville',
}) => User(
  id: id,
  name: name,
  username: username,
  email: email,
  phone: '0123 456 789',
  website: 'example.com',
  address: Address(
    street: '1 Test Street',
    suite: 'Suite 1',
    city: city,
    zipcode: '12345',
    geo: const Geo(lat: 0, lng: 0),
  ),
  company: Company(
    name: company,
    catchPhrase: 'Testing things',
    bs: 'test-driven synergy',
  ),
);

/// [count] made-up users with ids from [firstId].
List<User> testUsers(int count, {int firstId = 1}) => [
  for (var id = firstId; id < firstId + count; id++)
    testUser(id: id, name: 'Person $id'),
];

/// A window holding [users] as its first page, of a list of [total].
PagedWindow<User> windowOf(
  List<User> users, {
  int? total,
  int pageSize = 20,
  int maxPages = 3,
}) => PagedWindow<User>(
  pageSize: pageSize,
  maxPages: maxPages,
).withPage(0, users, total: total ?? users.length);
