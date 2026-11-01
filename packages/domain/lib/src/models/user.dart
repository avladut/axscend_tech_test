import 'package:domain/src/models/address.dart';
import 'package:domain/src/models/company.dart';
import 'package:equatable/equatable.dart';

/// A person in the directory. Albums, posts and todos each belong to one.
class User extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  final int id;
  final String name;
  final String username;
  final String email;

  /// As the backend gives it, such as `1-770-736-8031 x56442`.
  final String phone;

  /// A bare host such as `hildegard.org`, without a scheme.
  final String website;

  final Address address;
  final Company company;

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
    phone,
    website,
    address,
    company,
  ];
}
