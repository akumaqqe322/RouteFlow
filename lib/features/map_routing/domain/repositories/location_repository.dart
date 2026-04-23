import 'package:route_flow/features/map_routing/domain/entities/location_data.dart';

enum LocationPermissionStatus {
  denied,
  deniedForever,
  disabled,
  granted,
}

abstract class LocationRepository {
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData> getCurrentLocation();
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
  Stream<LocationData> get locationStream;
}
