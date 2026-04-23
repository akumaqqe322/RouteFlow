import 'package:equatable/equatable.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

enum SavedRoutesStatus { initial, loading, success, failure }

class SavedRoutesState extends Equatable {
  final SavedRoutesStatus status;
  final List<SavedRoute> routes;
  final String? error;

  const SavedRoutesState({
    this.status = SavedRoutesStatus.initial,
    this.routes = const [],
    this.error,
  });

  SavedRoutesState copyWith({
    SavedRoutesStatus? status,
    List<SavedRoute>? routes,
    String? error,
  }) {
    return SavedRoutesState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, routes, error];
}
