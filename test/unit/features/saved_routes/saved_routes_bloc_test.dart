import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_state.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';

class MockSavedRoutesRepository extends Mock implements SavedRoutesRepository {}

void main() {
  late SavedRoutesRepository repository;
  late SavedRoutesBloc bloc;

  setUpAll(() {
    registerFallbackValue(SavedRoute(
      id: '',
      title: '',
      points: [],
      distance: 0,
      duration: 0,
      createdAt: DateTime.now(),
      isFavorite: false,
      startLat: 0,
      startLng: 0,
      endLat: 0,
      endLng: 0,
    ));
  });

  setUp(() {
    repository = MockSavedRoutesRepository();
    bloc = SavedRoutesBloc(repository);
  });

  group('SavedRoutesBloc', () {
    final testRoute = SavedRoute(
      id: '1',
      title: 'Test Route',
      points: [],
      distance: 1000,
      duration: 600,
      createdAt: DateTime(2024, 1, 1),
      isFavorite: false,
      startLat: 0,
      startLng: 0,
      endLat: 0,
      endLng: 0,
    );

    blocTest<SavedRoutesBloc, SavedRoutesState>(
      'emits [loading, success] when routes are loaded successfully',
      build: () {
        when(() => repository.getRoutes(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testRoute]);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedRoutes()),
      expect: () => [
        const SavedRoutesState(status: SavedRoutesStatus.loading),
        SavedRoutesState(status: SavedRoutesStatus.success, routes: [testRoute]),
      ],
    );

    blocTest<SavedRoutesBloc, SavedRoutesState>(
      'triggers LoadSavedRoutes after successful SaveBuiltRoute',
      build: () {
        when(() => repository.saveRoute(any())).thenAnswer((_) async {});
        // Mock getRoutes for the subsequent LoadSavedRoutes event
        when(() => repository.getRoutes(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [testRoute]);
        return bloc;
      },
      act: (bloc) => bloc.add(SaveBuiltRoute(
        title: 'New Route',
        start: const LatLng(0, 0),
        destination: const LatLng(1, 1),
        routeInfo: const RouteInfo(points: [], distance: 100, duration: 10),
      )),
      expect: () => [
        const SavedRoutesState(status: SavedRoutesStatus.loading),
        SavedRoutesState(status: SavedRoutesStatus.success, routes: [testRoute]),
      ],
      verify: (_) {
        verify(() => repository.saveRoute(any())).called(1);
      },
    );

    blocTest<SavedRoutesBloc, SavedRoutesState>(
      'triggers LoadSavedRoutes after successful DeleteRoute',
      build: () {
        when(() => repository.deleteRoute(any())).thenAnswer((_) async {});
        when(() => repository.getRoutes(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRoute('1')),
      expect: () => [
        const SavedRoutesState(status: SavedRoutesStatus.loading),
        const SavedRoutesState(status: SavedRoutesStatus.success, routes: []),
      ],
      verify: (_) {
        verify(() => repository.deleteRoute('1')).called(1);
      },
    );

    blocTest<SavedRoutesBloc, SavedRoutesState>(
      'emits [loading, failure] when storage error occurs',
      build: () {
        when(() => repository.getRoutes(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('Storage error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedRoutes()),
      expect: () => [
        const SavedRoutesState(status: SavedRoutesStatus.loading),
        const SavedRoutesState(status: SavedRoutesStatus.failure, error: 'storage_error'),
      ],
    );

    blocTest<SavedRoutesBloc, SavedRoutesState>(
      'emits [loading, failure] when auth error occurs',
      build: () {
        when(() => repository.getRoutes(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(SavedRoutesAuthFailure());
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSavedRoutes()),
      expect: () => [
        const SavedRoutesState(status: SavedRoutesStatus.loading),
        const SavedRoutesState(status: SavedRoutesStatus.failure, error: 'auth_error'),
      ],
    );
  });
}
