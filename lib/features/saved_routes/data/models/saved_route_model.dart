import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

@HiveType(typeId: 0)
class SavedRouteModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late double startLat;

  @HiveField(4)
  late double startLng;

  @HiveField(5)
  late double endLat;

  @HiveField(6)
  late double endLng;

  @HiveField(7)
  late double distance;

  @HiveField(8)
  late double duration;

  @HiveField(9)
  late List<double> polylineFlattened; // [lat1, lng1, lat2, lng2...]

  @HiveField(10)
  late bool isFavorite;

  @HiveField(11)
  late DateTime createdAt;

  @HiveField(12)
  late DateTime updatedAt;

  SavedRouteModel();

  SavedRouteModel.fromEntity(SavedRoute entity) {
    id = entity.id;
    userId = entity.userId;
    title = entity.title;
    startLat = entity.startLat;
    startLng = entity.startLng;
    endLat = entity.endLat;
    endLng = entity.endLng;
    distance = entity.distance;
    duration = entity.duration;
    isFavorite = entity.isFavorite;
    createdAt = entity.createdAt;
    updatedAt = entity.updatedAt;
    
    polylineFlattened = [];
    for (var p in entity.points) {
      polylineFlattened.add(p.latitude);
      polylineFlattened.add(p.longitude);
    }
  }

  SavedRoute toEntity() {
    List<LatLng> points = [];
    for (int i = 0; i < polylineFlattened.length; i += 2) {
      points.add(LatLng(polylineFlattened[i], polylineFlattened[i + 1]));
    }

    return SavedRoute(
      id: id,
      userId: userId,
      title: title,
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      distance: distance,
      duration: duration,
      points: points,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'distance': distance,
      'duration': duration,
      'polyline_data': polylineFlattened,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SavedRouteModel.fromJson(Map<String, dynamic> json) {
    final model = SavedRouteModel();
    model.id = json['id'];
    model.userId = json['user_id'];
    model.title = json['title'];
    model.startLat = (json['start_lat'] as num).toDouble();
    model.startLng = (json['start_lng'] as num).toDouble();
    model.endLat = (json['end_lat'] as num).toDouble();
    model.endLng = (json['end_lng'] as num).toDouble();
    model.distance = (json['distance'] as num).toDouble();
    model.duration = (json['duration'] as num).toDouble();
    model.isFavorite = json['is_favorite'] ?? false;
    model.createdAt = DateTime.parse(json['created_at']);
    model.updatedAt = DateTime.parse(json['updated_at']);
    model.polylineFlattened = List<double>.from(
      (json['polyline_data'] as List).map((e) => (e as num).toDouble())
    );
    return model;
  }
}
