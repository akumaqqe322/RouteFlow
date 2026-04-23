import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription _authSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<LogoutRequested>(_onLogoutRequested);

    _authSubscription = _authRepository.onAuthStateChanged.listen(
      (user) => add(AuthUserChanged(user)),
    );

    // Initial check
    final user = _authRepository.currentUser;
    add(AuthUserChanged(user));
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
