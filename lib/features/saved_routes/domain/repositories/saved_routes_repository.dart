import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';

abstract class SavedRoutesRepository {
  Future<List<SavedRoute>> getRoutes({bool forceRefresh = false});
  Future<SavedRoute?> getRouteById(String id);
  Future<void> saveRoute(SavedRoute route);
  Future<void> updateRoute(SavedRoute route);
  Future<void> deleteRoute(String id);
}
