import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:route_flow/features/auth/domain/entities/auth_user.dart';
import 'package:route_flow/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _client;

  SupabaseAuthRepository() : _client = sb.Supabase.instance.client;

  @override
  Stream<AuthUser?> get onAuthStateChanged => 
      _client.auth.onAuthStateChange.map((data) => _mapUser(data.session?.user));

  @override
  AuthUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  AuthUser? _mapUser(sb.User? user) {
    if (user == null) return null;
    return AuthUser(id: user.id, email: user.email ?? '');
  }
}
