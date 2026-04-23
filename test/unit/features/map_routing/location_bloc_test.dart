import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/core/error/location_failure.dart';
import 'package:route_flow/features/map_routing/domain/repositories/location_repository.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_state.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late LocationRepository repository;
  late LocationBloc bloc;

  setUp(() {
    repository = MockLocationRepository();
    bloc = LocationBloc(repository);
  });

  group('LocationBloc', () {
    const testLocation = LatLng(55.7558, 37.6173);

    blocTest<LocationBloc, LocationState>(
      'emits [success] when location is fetched successfully',
      build: () {
        when(() => repository.getCurrentLocation()).thenAnswer((_) async => testLocation);
        return bloc;
      },
      act: (bloc) => bloc.add(GetCurrentLocation()),
      expect: () => [
        const LocationState(status: LocationStatus.loading),
        const LocationState(status: LocationStatus.success, location: testLocation),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [servicesDisabled] when location services are disabled',
      build: () {
        when(() => repository.getCurrentLocation()).thenThrow(LocationDisabledFailure());
        return bloc;
      },
      act: (bloc) => bloc.add(GetCurrentLocation()),
      expect: () => [
        const LocationState(status: LocationStatus.loading),
        const LocationState(status: LocationStatus.servicesDisabled),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [permissionDenied] when permission is denied',
      build: () {
        when(() => repository.requestPermission()).thenAnswer((_) async => LocationPermissionStatus.denied);
        return bloc;
      },
      act: (bloc) => bloc.add(RequestLocationPermission()),
      expect: () => [
        const LocationState(status: LocationStatus.loading),
        const LocationState(status: LocationStatus.permissionDenied),
      ],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [permissionPermanentlyDenied] when permission is permanently denied',
      build: () {
        when(() => repository.requestPermission()).thenAnswer((_) async => LocationPermissionStatus.deniedForever);
        return bloc;
      },
      act: (bloc) => bloc.add(RequestLocationPermission()),
      expect: () => [
        const LocationState(status: LocationStatus.loading),
        const LocationState(status: LocationStatus.permissionPermanentlyDenied),
      ],
    );
  });
}
