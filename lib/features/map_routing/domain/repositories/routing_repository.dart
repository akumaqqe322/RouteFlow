import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';

abstract class RoutingRepository {
  Future<RouteInfo> getRoute({
    required LatLng start,
    required LatLng destination,
  });
}
