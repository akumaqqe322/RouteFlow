import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/core/error/route_failure.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:route_flow/features/map_routing/domain/repositories/routing_repository.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_state.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';

class MockRoutingRepository extends Mock implements RoutingRepository {}
class MockSavedRoutesRepository extends Mock implements SavedRoutesRepository {}

void main() {
  late RoutingRepository routingRepository;
  late SavedRoutesRepository savedRoutesRepository;
  late RouteBloc bloc;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    routingRepository = MockRoutingRepository();
    savedRoutesRepository = MockSavedRoutesRepository();
    bloc = RouteBloc(routingRepository, savedRoutesRepository);
  });

  group('RouteBloc', () {
    const start = LatLng(0, 0);
    const destination = LatLng(1, 1);
    final testRoute = RouteInfo(points: [start, destination], distance: 1000, duration: 60);

    blocTest<RouteBloc, RouteState>(
      'emits [loading, success] when route building is successful',
      build: () {
        when(() => routingRepository.getRoute(
          start: any(named: 'start'),
          destination: any(named: 'destination'),
        )).thenAnswer((_) async => testRoute);
        return bloc;
      },
      act: (bloc) => bloc.add(const BuildRouteRequested(start: start, destination: destination)),
      expect: () => [
        const RouteState(status: RouteStatus.loading, destination: destination),
        RouteState(status: RouteStatus.success, destination: destination, route: testRoute),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'emits [loading, failure] when route building fails',
      build: () {
        when(() => routingRepository.getRoute(
          start: any(named: 'start'),
          destination: any(named: 'destination'),
        )).thenThrow(const RouteNetworkFailure());
        return bloc;
      },
      act: (bloc) => bloc.add(const BuildRouteRequested(start: start, destination: destination)),
      expect: () => [
        const RouteState(status: RouteStatus.loading, destination: destination),
        const RouteState(status: RouteStatus.failure, destination: destination, error: 'network_error'),
      ],
    );

    blocTest<RouteBloc, RouteState>(
      'emits [] if BuildRouteRequested is called while loading',
      build: () {
        when(() => routingRepository.getRoute(
          start: any(named: 'start'),
          destination: any(named: 'destination'),
        )).thenAnswer((_) async => testRoute);
        return bloc;
      },
      seed: () => const RouteState(status: RouteStatus.loading),
      act: (bloc) => bloc.add(const BuildRouteRequested(start: start, destination: destination)),
      expect: () => [],
    );
  });
}
