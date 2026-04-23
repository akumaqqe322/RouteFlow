import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/core/config/app_config.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:route_flow/features/map_routing/domain/repositories/routing_repository.dart';
import 'package:route_flow/core/error/route_failure.dart';

@LazySingleton(as: RoutingRepository)
class OsrmRoutingRepository implements RoutingRepository {
  final Dio _dio;

  OsrmRoutingRepository(this._dio);

  @override
  Future<RouteInfo> getRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    try {
      final String url = '${AppConfig.osrmBaseUrl}/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
      );

      if (response.data['code'] == 'NoRoute') {
        throw const RouteNotFoundFailure();
      }

      if (response.data['code'] != 'Ok') {
        throw UnexpectedRouteFailure(response.data['code']);
      }

      final route = response.data['routes'][0];
      final geometry = route['geometry']['coordinates'] as List;
      
      final List<LatLng> points = geometry
          .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
          .toList();

      return RouteInfo(
        points: points,
        distance: (route['distance'] as num).toDouble(),
        duration: (route['duration'] as num).toDouble(),
      );
    } on DioException {
      throw const RouteNetworkFailure();
    } on RouteFailure {
      rethrow;
    } catch (e) {
      throw UnexpectedRouteFailure(e.toString());
    }
  }
}
