import 'package:route_flow/core/error/failures.dart';

abstract class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('invalid_credentials');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure() : super('email_already_in_use');
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure() : super('network_failure');
}

class UnexpectedAuthFailure extends AuthFailure {
  const UnexpectedAuthFailure([String? message]) : super(message ?? 'unexpected_error');
}
