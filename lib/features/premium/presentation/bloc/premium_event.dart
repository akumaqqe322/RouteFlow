import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();
  @override
  List<Object?> get props => [];
}

class InitializePremium extends PremiumEvent {
  final String userId;
  const InitializePremium(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadPremiumOfferings extends PremiumEvent {}

class PurchasePackage extends PremiumEvent {
  final Package package;
  const PurchasePackage(this.package);
  @override
  List<Object?> get props => [package];
}

class RestorePurchases extends PremiumEvent {}
