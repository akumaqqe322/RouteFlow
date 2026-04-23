import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';

abstract class PremiumRepository {
  Future<void> initialize(String userId);
  Future<PremiumStatus> getStatus();
  Future<Offerings> getOfferings();
  Future<bool> purchasePackage(Package package);
  Future<PremiumStatus> restorePurchases();
}
