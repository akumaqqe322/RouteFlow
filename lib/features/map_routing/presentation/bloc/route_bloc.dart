import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/domain/repositories/routing_repository.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_state.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';
import 'package:route_flow/core/error/route_failure.dart';

@injectable
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final RoutingRepository _repository;
  final SavedRoutesRepository _savedRoutesRepository;

  RouteBloc(this._repository, this._savedRoutesRepository) : super(const RouteState()) {
    on<BuildRouteRequested>(_onBuildRequested);
    on<ClearRouteRequested>(_onClearRequested);
    on<RestoreSavedRoute>(_onRestoreRequested);
    on<LoadSavedRouteById>(_onLoadById);
  }

  Future<void> _onLoadById(
    LoadSavedRouteById event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(status: RouteStatus.loading));
    try {
      final route = await _savedRoutesRepository.getRouteById(event.routeId);
      if (route != null) {
        add(RestoreSavedRoute(route));
      } else {
        emit(state.copyWith(status: RouteStatus.failure, error: 'route_not_found'));
      }
    } catch (_) {
      emit(state.copyWith(status: RouteStatus.failure, error: 'storage_error'));
    }
  }

  void _onRestoreRequested(
    RestoreSavedRoute event,
    Emitter<RouteState> emit,
  ) {
    final route = event.route;
    emit(state.copyWith(
      status: RouteStatus.success,
      destination: LatLng(route.endLat, route.endLng),
      route: RouteInfo(
        points: route.points,
        distance: route.distance,
        duration: route.duration,
      ),
    ));
  }

  Future<void> _onBuildRequested(
    BuildRouteRequested event,
    Emitter<RouteState> emit,
  ) async {
    // 1. Prevent overlapping requests
    if (state.status == RouteStatus.loading) return;

    emit(state.copyWith(
      status: RouteStatus.loading,
      destination: event.destination,
      error: null,
    ));

    try {
      final route = await _repository.getRoute(
        start: event.start,
        destination: event.destination,
      );
      emit(state.copyWith(
        status: RouteStatus.success,
        route: route,
      ));
    } on RouteFailure catch (e) {
      emit(state.copyWith(
        status: RouteStatus.failure,
        error: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteStatus.failure,
        error: 'unexpected_error',
      ));
    }
  }

  void _onClearRequested(
    ClearRouteRequested event,
    Emitter<RouteState> emit,
  ) {
    emit(const RouteState());
  }
}
