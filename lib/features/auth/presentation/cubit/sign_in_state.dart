import 'package:equatable/equatable.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final String email;
  final String password;
  final SignInStatus status;
  final String? errorMessage;
  final bool isLoginMode;

  const SignInState({
    this.email = '',
    this.password = '',
    this.status = SignInStatus.initial,
    this.errorMessage,
    this.isLoginMode = true,
  });

  SignInState copyWith({
    String? email,
    String? password,
    SignInStatus? status,
    String? errorMessage,
    bool? isLoginMode,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoginMode: isLoginMode ?? this.isLoginMode,
    );
  }

  bool get isValid => email.contains('@') && password.length >= 6;

  @override
  List<Object?> get props => [email, password, status, errorMessage, isLoginMode];
}
