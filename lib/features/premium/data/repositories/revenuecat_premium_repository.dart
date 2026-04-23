import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/core/config/app_config.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';
import 'package:route_flow/features/premium/domain/repositories/premium_repository.dart';

@LazySingleton(as: PremiumRepository)
class RevenueCatPremiumRepository implements PremiumRepository {
  static const _entitlementId = 'premium';

  @override
  Future<void> initialize(String userId) async {
    // In a real app, API Keys would be per platform
    final apiKey = Platform.isIOS ? 'goog_dummy_ios' : 'goog_dummy_android';
    
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    configuration.appUserId = userId;
    await Purchases.configure(configuration);
  }

  @override
  Future<PremiumStatus> getStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfo(customerInfo);
    } catch (_) {
      return PremiumStatus.free();
    }
  }

  @override
  Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    CustomerInfo customerInfo = await Purchases.restorePurchases();
    return _mapCustomerInfo(customerInfo);
  }

  PremiumStatus _mapCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[_entitlementId];
    return PremiumStatus(
      isPremium: entitlement?.isActive ?? false,
      expirationDate: entitlement?.expirationDate != null 
          ? DateTime.parse(entitlement!.expirationDate!) 
          : null,
    );
  }
}
