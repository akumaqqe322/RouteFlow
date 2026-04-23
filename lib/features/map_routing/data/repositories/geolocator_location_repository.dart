import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/map_routing/domain/entities/location_data.dart';
import 'package:route_flow/features/map_routing/domain/repositories/location_repository.dart';
import 'package:route_flow/core/error/location_failure.dart';

@LazySingleton(as: LocationRepository)
class GeolocatorLocationRepository implements LocationRepository {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.disabled;

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw const LocationDisabledFailure();

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedFailure();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedFailure();
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationData(latitude: position.latitude, longitude: position.longitude);
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Stream<LocationData> get locationStream => 
      Geolocator.getPositionStream().map((pos) => 
          LocationData(latitude: pos.latitude, longitude: pos.longitude));

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }
}
