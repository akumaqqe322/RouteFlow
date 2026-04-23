import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/core/config/app_config.dart';
import 'package:route_flow/core/error/premium_failure.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';
import 'package:route_flow/features/premium/domain/repositories/premium_repository.dart';

@LazySingleton(as: PremiumRepository)
class RevenueCatPremiumRepository implements PremiumRepository {
  static const _entitlementId = 'premium';

  @override
  Future<void> initialize(String userId) async {
    if (!AppConfig.enablePremiumPurchases) {
      debugPrint('[PremiumRepository] Purchases disabled for this platform or configuration.');
      return;
    }

    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final apiKey = isIOS 
        ? AppConfig.revenueCatApiKeyIos 
        : AppConfig.revenueCatApiKeyAndroid;
    
    if (apiKey.isEmpty) {
      throw const PremiumConfigurationFailure();
    }
    
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    configuration.appUserId = userId;
    await Purchases.configure(configuration);
  }

  @override
  Future<PremiumStatus> getStatus() async {
    try {
      if (!AppConfig.enablePremiumPurchases) {
        return PremiumStatus.free();
      }
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _mapCustomerInfo(customerInfo);
    } catch (_) {
      return PremiumStatus.free();
    }
  }

  @override
  Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      throw const PremiumOfferingsLoadFailure();
    }
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      if (e.code == '1') { // RevenueCat code for Cancellation
        throw const PremiumPurchaseCancelledFailure();
      }
      throw PremiumPurchaseFailedFailure(e.message);
    }
  }

  @override
  Future<PremiumStatus> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return _mapCustomerInfo(customerInfo);
    } catch (e) {
      throw const PremiumPurchaseFailedFailure('restore_failed');
    }
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
