import 'package:domain/src/models/geo.dart';
import 'package:equatable/equatable.dart';

/// A `User`'s postal address.
class Address extends Equatable {
  const new({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  @override
  List<Object?> get props => [street, suite, city, zipcode, geo];
}
