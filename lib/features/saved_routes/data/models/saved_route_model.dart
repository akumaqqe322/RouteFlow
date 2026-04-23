import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

class SavedRouteModel {
  static SavedRoute fromEntity(SavedRoute entity) => entity;

  static Map<String, dynamic> toJson(SavedRoute route) {
    return {
      'id': route.id,
      'user_id': route.userId,
      'title': route.title,
      'start_lat': route.startLat,
      'start_lng': route.startLng,
      'end_lat': route.endLat,
      'end_lng': route.endLng,
      'distance': route.distance,
      'duration': route.duration,
      'polyline_data': route.points.map((p) => [p.latitude, p.longitude]).toList(),
      'is_favorite': route.isFavorite,
      'created_at': route.createdAt.toIso8601String(),
      'updated_at': route.updatedAt.toIso8601String(),
    };
  }

  static SavedRoute fromJson(Map<String, dynamic> json) {
    final List<dynamic> polyData = json['polyline_data'] ?? [];
    final List<LatLng> points = polyData.map((coord) {
      if (coord is List) {
        return LatLng(coord[0].toDouble(), coord[1].toDouble());
      }
      return const LatLng(0, 0);
    }).toList();

    return SavedRoute(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      startLat: (json['start_lat'] as num).toDouble(),
      startLng: (json['start_lng'] as num).toDouble(),
      endLat: (json['end_lat'] as num).toDouble(),
      endLng: (json['end_lng'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      points: points,
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
