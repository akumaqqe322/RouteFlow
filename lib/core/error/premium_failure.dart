import 'package:route_flow/core/error/failures.dart';

abstract class PremiumFailure extends Failure {
  const PremiumFailure(super.message);
}

class PremiumPurchaseCancelledFailure extends PremiumFailure {
  const PremiumPurchaseCancelledFailure() : super('purchase_cancelled');
}

class PremiumPurchaseFailedFailure extends PremiumFailure {
  const PremiumPurchaseFailedFailure([String? message]) : super(message ?? 'purchase_failed');
}

class PremiumOfferingsLoadFailure extends PremiumFailure {
  const PremiumOfferingsLoadFailure() : super('offerings_load_failed');
}

class PremiumConfigurationFailure extends PremiumFailure {
  const PremiumConfigurationFailure() : super('premium_config_missing');
}
