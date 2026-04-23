import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/map_routing/domain/repositories/routing_repository.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_state.dart';

@injectable
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final RoutingRepository _repository;

  RouteBloc(this._repository) : super(const RouteState()) {
    on<BuildRouteRequested>(_onBuildRequested);
    on<ClearRouteRequested>(_onClearRequested);
  }

  Future<void> _onBuildRequested(
    BuildRouteRequested event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(
      status: RouteStatus.loading,
      destination: event.destination,
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
    } catch (e) {
      emit(state.copyWith(
        status: RouteStatus.failure,
        error: e.toString(),
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
