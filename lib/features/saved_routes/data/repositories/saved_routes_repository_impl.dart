import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_flow/features/saved_routes/data/models/saved_route_model.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';

@LazySingleton(as: SavedRoutesRepository)
class SavedRoutesRepositoryImpl implements SavedRoutesRepository {
  final SupabaseClient _supabase;
  static const _boxName = 'saved_routes_cache';

  SavedRoutesRepositoryImpl(this._supabase);

  Future<Box<SavedRouteModel>> get _box async => Hive.openBox<SavedRouteModel>(_boxName);

  @override
  Future<List<SavedRoute>> getRoutes({bool forceRefresh = false}) async {
    final box = await _box;
    
    // 1. Try Cache first unless forced
    if (!forceRefresh && box.isNotEmpty) {
      return box.values.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // 2. Refresh from Remote
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('routes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<SavedRouteModel> remoteModels = (response as List)
        .map((json) => SavedRouteModel.fromJson(json))
        .toList();

    // 3. Update Cache
    await box.clear();
    for (var m in remoteModels) {
      await box.put(m.id, m);
    }

    return remoteModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveRoute(SavedRoute route) async {
    final model = SavedRouteModel.fromEntity(route);
    
    // Remote first
    await _supabase.from('routes').upsert(model.toJson());
    
    // Cache second
    final box = await _box;
    await box.put(model.id, model);
  }

  @override
  Future<void> updateRoute(SavedRoute route) async {
    final model = SavedRouteModel.fromEntity(route);
    
    await _supabase.from('routes').update(model.toJson()).eq('id', route.id);
    
    final box = await _box;
    await box.put(model.id, model);
  }

  @override
  Future<void> deleteRoute(String id) async {
    await _supabase.from('routes').delete().eq('id', id);
    
    final box = await _box;
    await box.delete(id);
  }
}
