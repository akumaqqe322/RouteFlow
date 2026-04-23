import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object?> get props => [];
}

class BuildRouteRequested extends RouteEvent {
  final LatLng start;
  final LatLng destination;
  const BuildRouteRequested({required this.start, required this.destination});
  @override
  List<Object?> get props => [start, destination];
}

class ClearRouteRequested extends RouteEvent {}

class RestoreSavedRoute extends RouteEvent {
  final SavedRoute route;
  const RestoreSavedRoute(this.route);
  @override
  List<Object?> get props => [route];
}
