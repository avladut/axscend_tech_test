import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';

/// A user as `/users` sends it.
class UserDto {
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

  factory fromJson(Object? json) => switch (json) {
    {
      'id': final int id,
      'name': final String name,
      'username': final String username,
      'email': final String email,
      'phone': final String phone,
      'website': final String website,
      'address': final Object? address,
      'company': final Object? company,
    } =>
      UserDto(
        id: id,
        name: name,
        username: username,
        email: email,
        phone: phone,
        website: website,
        address: AddressDto.fromJson(address),
        company: CompanyDto.fromJson(company),
      ),
    _ => throw invalidJson('user', json),
  };

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final AddressDto address;
  final CompanyDto company;

  User toDomain() => User(
    id: id,
    name: name,
    username: username,
    email: email,
    phone: phone,
    website: website,
    address: address.toDomain(),
    company: company.toDomain(),
  );
}

/// A user's `address` object.
class AddressDto {
  const new({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory fromJson(Object? json) => switch (json) {
    {
      'street': final String street,
      'suite': final String suite,
      'city': final String city,
      'zipcode': final String zipcode,
      'geo': final Object? geo,
    } =>
      AddressDto(
        street: street,
        suite: suite,
        city: city,
        zipcode: zipcode,
        geo: GeoDto.fromJson(geo),
      ),
    _ => throw invalidJson('address', json),
  };

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final GeoDto geo;

  Address toDomain() => Address(
    street: street,
    suite: suite,
    city: city,
    zipcode: zipcode,
    geo: geo.toDomain(),
  );
}

/// An address's `geo` object. The API sends the coordinates as strings.
class GeoDto {
  const new({required this.lat, required this.lng});

  factory fromJson(Object? json) => switch (json) {
    {'lat': final String lat, 'lng': final String lng} => GeoDto(
      lat: lat,
      lng: lng,
    ),
    _ => throw invalidJson('geo', json),
  };

  final String lat;
  final String lng;

  Geo toDomain() => switch ((double.tryParse(lat), double.tryParse(lng))) {
    (final double latitude, final double longitude) => Geo(
      lat: latitude,
      lng: longitude,
    ),
    _ => throw invalidJson('geo', {'lat': lat, 'lng': lng}),
  };
}

/// A user's `company` object.
class CompanyDto {
  const new({required this.name, required this.catchPhrase, required this.bs});

  factory fromJson(Object? json) => switch (json) {
    {
      'name': final String name,
      'catchPhrase': final String catchPhrase,
      'bs': final String bs,
    } =>
      CompanyDto(name: name, catchPhrase: catchPhrase, bs: bs),
    _ => throw invalidJson('company', json),
  };

  final String name;
  final String catchPhrase;
  final String bs;

  Company toDomain() => Company(name: name, catchPhrase: catchPhrase, bs: bs);
}
