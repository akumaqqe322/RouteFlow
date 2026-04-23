import 'package:equatable/equatable.dart';
import 'package:route_flow/features/map_routing/domain/entities/location_data.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  failure,
  permissionDenied,
  permissionPermanentlyDenied,
  servicesDisabled,
}

class LocationState extends Equatable {
  final LocationStatus status;
  final LocationData? location;
  final String? error;

  const LocationState({
    this.status = LocationStatus.initial,
    this.location,
    this.error,
  });

  LocationState copyWith({
    LocationStatus? status,
    LocationData? location,
    String? error,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, location, error];
}
