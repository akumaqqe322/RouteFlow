import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object?> get props => [];
}

class RequestLocationPermission extends LocationEvent {}

class GetCurrentLocation extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final double latitude;
  final double longitude;
  const UpdateLocation(this.latitude, this.longitude);
  @override
  List<Object?> get props => [latitude, longitude];
}

class OpenLocationSettings extends LocationEvent {
  final bool isAppSettings;
  const OpenLocationSettings({this.isAppSettings = true});
  @override
  List<Object?> get props => [isAppSettings];
}
