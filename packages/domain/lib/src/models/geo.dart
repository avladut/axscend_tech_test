import 'package:equatable/equatable.dart';

/// Where an `Address` is on the map.
class Geo extends Equatable {
  const new({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}
