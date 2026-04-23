import 'package:equatable/equatable.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

abstract class SavedRoutesEvent extends Equatable {
  const SavedRoutesEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavedRoutes extends SavedRoutesEvent {
  final bool forceRefresh;
  const LoadSavedRoutes({this.forceRefresh = false});
  @override
  List<Object?> get props => [forceRefresh];
}

class SaveBuiltRoute extends SavedRoutesEvent {
  final String title;
  final dynamic routeInfo;
  final dynamic start;
  final dynamic destination;
  const SaveBuiltRoute({
    required this.title,
    required this.routeInfo,
    required this.start,
    required this.destination,
  });
  @override
  List<Object?> get props => [title, routeInfo, start, destination];
}

class ToggleFavoriteRoute extends SavedRoutesEvent {
  final SavedRoute route;
  const ToggleFavoriteRoute(this.route);
  @override
  List<Object?> get props => [route];
}

class RenameRoute extends SavedRoutesEvent {
  final SavedRoute route;
  final String newTitle;
  const RenameRoute(this.route, this.newTitle);
  @override
  List<Object?> get props => [route, newTitle];
}

class DeleteRoute extends SavedRoutesEvent {
  final String id;
  const DeleteRoute(this.id);
  @override
  List<Object?> get props => [id];
}
