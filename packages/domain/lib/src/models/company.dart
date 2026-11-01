import 'package:equatable/equatable.dart';

/// Where a `User` works.
class Company extends Equatable {
  const new({required this.name, required this.catchPhrase, required this.bs});

  final String name;
  final String catchPhrase;

  /// What the company does, as buzzwords.
  final String bs;

  @override
  List<Object?> get props => [name, catchPhrase, bs];
}
