import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class SavedRoute extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final double distance;
  final double duration;
  final List<LatLng> points;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRoute({
    required this.id,
    required this.userId,
    required this.title,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.distance,
    required this.duration,
    required this.points,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  SavedRoute copyWith({
    String? title,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return SavedRoute(
      id: id,
      userId: userId,
      title: title ?? this.title,
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      distance: distance,
      duration: duration,
      points: points,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        isFavorite,
        updatedAt,
      ];
}
