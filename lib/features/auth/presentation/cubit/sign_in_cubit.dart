import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:route_flow/features/auth/presentation/cubit/sign_in_state.dart';

@injectable
class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository;

  SignInCubit(this._authRepository) : super(const SignInState());

  void emailChanged(String value) => emit(state.copyWith(email: value, status: SignInStatus.initial));
  void passwordChanged(String value) => emit(state.copyWith(password: value, status: SignInStatus.initial));
  void toggleMode() => emit(state.copyWith(isLoginMode: !state.isLoginMode, status: SignInStatus.initial));

  Future<void> submit() async {
    if (!state.isValid || state.status == SignInStatus.loading) return;

    emit(state.copyWith(status: SignInStatus.loading));

    try {
      if (state.isLoginMode) {
        await _authRepository.signInWithEmail(
          email: state.email,
          password: state.password,
        );
      } else {
        await _authRepository.signUpWithEmail(
          email: state.email,
          password: state.password,
        );
      }
      emit(state.copyWith(status: SignInStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
