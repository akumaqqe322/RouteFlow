import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RouteInfo extends Equatable {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds

  const RouteInfo({
    required this.points,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props => [points, distance, duration];
}
