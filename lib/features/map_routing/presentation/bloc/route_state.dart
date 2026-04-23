import 'package:equatable/equatable.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:latlong2/latlong.dart';

enum RouteStatus { initial, loading, success, failure }

class RouteState extends Equatable {
  final RouteStatus status;
  final RouteInfo? route;
  final LatLng? destination;
  final String? error;

  const RouteState({
    this.status = RouteStatus.initial,
    this.route,
    this.destination,
    this.error,
  });

  RouteState copyWith({
    RouteStatus? status,
    RouteInfo? route,
    LatLng? destination,
    String? error,
  }) {
    return RouteState(
      status: status ?? this.status,
      route: route ?? this.route,
      destination: destination ?? this.destination,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, route, destination, error];
}
