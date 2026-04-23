import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/map_routing/domain/repositories/location_repository.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_state.dart';

@injectable
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;

  LocationBloc(this._repository) : super(const LocationState()) {
    on<RequestLocationPermission>(_onPermissionRequested);
    on<GetCurrentLocation>(_onGetLocation);
    on<UpdateLocation>(_onUpdateLocation);
  }

  Future<void> _onPermissionRequested(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.loading));
    
    final status = await _repository.requestPermission();
    
    if (status == LocationPermissionStatus.granted) {
      add(GetCurrentLocation());
    } else if (status == LocationPermissionStatus.deniedForever) {
      emit(state.copyWith(status: LocationStatus.permissionPermanentlyDenied));
    } else {
      emit(state.copyWith(status: LocationStatus.permissionDenied));
    }
  }

  Future<void> _onGetLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.loading));
    
    try {
      final location = await _repository.getCurrentLocation();
      emit(state.copyWith(
        status: LocationStatus.success,
        location: location,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateLocation(UpdateLocation event, Emitter<LocationState> emit) {
    // Used for potential real-time streaming or manual override
  }
}
