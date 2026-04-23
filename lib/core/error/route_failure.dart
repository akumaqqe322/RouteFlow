import 'package:route_flow/core/error/failures.dart';

abstract class RouteFailure extends Failure {
  const RouteFailure(super.message);
}

class RouteNotFoundFailure extends RouteFailure {
  const RouteNotFoundFailure() : super('route_not_found');
}

class RouteNetworkFailure extends RouteFailure {
  const RouteNetworkFailure() : super('route_network_error');
}

class UnexpectedRouteFailure extends RouteFailure {
  const UnexpectedRouteFailure([String? message]) : super(message ?? 'unexpected_route_error');
}
