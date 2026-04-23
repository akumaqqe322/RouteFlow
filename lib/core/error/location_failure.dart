import 'package:route_flow/core/error/failures.dart';

abstract class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class LocationDisabledFailure extends LocationFailure {
  const LocationDisabledFailure() : super('location_services_disabled');
}

class LocationPermissionDeniedFailure extends LocationFailure {
  const LocationPermissionDeniedFailure() : super('permission_denied');
}

class LocationPermissionPermanentlyDeniedFailure extends LocationFailure {
  const LocationPermissionPermanentlyDeniedFailure() : super('permission_permanently_denied');
}

class UnexpectedLocationFailure extends LocationFailure {
  const UnexpectedLocationFailure([String? message]) : super(message ?? 'unexpected_location_error');
}
