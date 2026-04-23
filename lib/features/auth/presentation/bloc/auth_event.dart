import 'package:equatable/equatable.dart';
import 'package:route_flow/features/auth/domain/entities/auth_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final AuthUser? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class LogoutRequested extends AuthEvent {}
