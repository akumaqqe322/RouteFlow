import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_flow/features/saved_routes/data/models/saved_route_model.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';
import 'package:route_flow/features/saved_routes/domain/repositories/saved_routes_repository.dart';
import 'package:route_flow/core/error/saved_routes_failure.dart';

@LazySingleton(as: SavedRoutesRepository)
class SavedRoutesRepositoryImpl implements SavedRoutesRepository {
  final SupabaseClient _supabase;
  static const _boxName = 'saved_routes_v1';

  SavedRoutesRepositoryImpl(this._supabase);

  Future<Box> get _box async => Hive.openBox(_boxName);

  @override
  Future<SavedRoute?> getRouteById(String id) async {
    // 1. Check Local Cache First
    final box = await Hive.openBox(_boxName);
    final localData = box.get(id);
    if (localData != null) {
      return SavedRouteModel.fromJson(Map<String, dynamic>.from(localData)).toEntity();
    }

    // 2. Fallback to Cloud
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw SavedRoutesAuthFailure();

    try {
      final response = await _supabase
          .from('saved_routes')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final model = SavedRouteModel.fromJson(response);
        await box.put(id, response); // Cache for next time
        return model.toEntity();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
    try {
      final box = await _box;
      
      // 1. Cache-first strategy
      if (!forceRefresh && box.isNotEmpty) {
        final List<SavedRoute> cachedRoutes = box.values
            .map((data) => SavedRouteModel.fromJson(Map<String, dynamic>.from(data)))
            .toList();
        cachedRoutes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return cachedRoutes;
      }

      // 2. Remote refresh
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw const SavedRoutesAuthFailure();

      final response = await _supabase
          .from('routes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> remoteData = List<Map<String, dynamic>>.from(response);
      final List<SavedRoute> remoteRoutes = remoteData
          .map((json) => SavedRouteModel.fromJson(json))
          .toList();

      // 3. Persistent Sync
      await box.clear();
      for (var json in remoteData) {
        await box.put(json['id'], json);
      }

      return remoteRoutes;
    } catch (e) {
      if (e is SavedRoutesFailure) rethrow;
      throw UnexpectedSavedRoutesFailure(e.toString());
    }
  }

  @override
  Future<void> saveRoute(SavedRoute route) async {
    try {
      final json = SavedRouteModel.toJson(route);
      
      // Remote
      await _supabase.from('routes').upsert(json);
      
      // Cache
      final box = await _box;
      await box.put(route.id, json);
    } catch (e) {
      throw UnexpectedSavedRoutesFailure(e.toString());
    }
  }

  @override
  Future<void> updateRoute(SavedRoute route) async {
    try {
      final json = SavedRouteModel.toJson(route);
      
      await _supabase.from('routes').update(json).eq('id', route.id);
      
      final box = await _box;
      await box.put(route.id, json);
    } catch (e) {
      throw UnexpectedSavedRoutesFailure(e.toString());
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    try {
      await _supabase.from('routes').delete().eq('id', id);
      
      final box = await _box;
      await box.delete(id);
    } catch (e) {
      throw UnexpectedSavedRoutesFailure(e.toString());
    }
  }
}
