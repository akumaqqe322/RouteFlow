import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_state.dart';

@injectable
class SavedRoutesBloc extends Bloc<SavedRoutesEvent, SavedRoutesState> {
  final SavedRoutesRepository _repository;
  final SupabaseClient _supabase;

  SavedRoutesBloc(this._repository, this._supabase) : super(const SavedRoutesState()) {
    on<LoadSavedRoutes>(_onLoadRoutes);
    on<SaveBuiltRoute>(_onSaveRoute);
    on<ToggleFavoriteRoute>(_onToggleFavorite);
    on<RenameRoute>(_onRename);
    on<DeleteRoute>(_onDelete);
  }

  Future<void> _onLoadRoutes(
    LoadSavedRoutes event,
    Emitter<SavedRoutesState> emit,
  ) async {
    emit(state.copyWith(status: SavedRoutesStatus.loading));
    try {
      final routes = await _repository.getRoutes(forceRefresh: event.forceRefresh);
      emit(state.copyWith(status: SavedRoutesStatus.success, routes: routes));
    } catch (e) {
      emit(state.copyWith(status: SavedRoutesStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSaveRoute(
    SaveBuiltRoute event,
    Emitter<SavedRoutesState> emit,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final newRoute = SavedRoute(
      id: const Uuid().v4(),
      userId: userId,
      title: event.title,
      startLat: event.start.latitude,
      startLng: event.start.longitude,
      endLat: event.destination.latitude,
      endLng: event.destination.longitude,
      distance: event.routeInfo.distance,
      duration: event.routeInfo.duration,
      points: event.routeInfo.points,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.saveRoute(newRoute);
      add(const LoadSavedRoutes(forceRefresh: true));
    } catch (e) {
      emit(state.copyWith(status: SavedRoutesStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteRoute event,
    Emitter<SavedRoutesState> emit,
  ) async {
    final updated = event.route.copyWith(
      isFavorite: !event.route.isFavorite,
      updatedAt: DateTime.now(),
    );
    try {
      await _repository.updateRoute(updated);
      add(const LoadSavedRoutes());
    } catch (e) {
      emit(state.copyWith(status: SavedRoutesStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRename(
    RenameRoute event,
    Emitter<SavedRoutesState> emit,
  ) async {
    final updated = event.route.copyWith(
      title: event.newTitle,
      updatedAt: DateTime.now(),
    );
    try {
      await _repository.updateRoute(updated);
      add(const LoadSavedRoutes());
    } catch (e) {
      emit(state.copyWith(status: SavedRoutesStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteRoute event,
    Emitter<SavedRoutesState> emit,
  ) async {
    try {
      await _repository.deleteRoute(event.id);
      add(const LoadSavedRoutes());
    } catch (e) {
      emit(state.copyWith(status: SavedRoutesStatus.failure, error: e.toString()));
    }
  }
}
