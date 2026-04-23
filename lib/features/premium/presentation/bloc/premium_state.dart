import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';

enum PremiumScreenStatus { initial, loading, success, failure, purchasing }

class PremiumState extends Equatable {
  final PremiumStatus status;
  final PremiumScreenStatus screenStatus;
  final Offerings? offerings;
  final String? error;

  const PremiumState({
    this.status = const PremiumStatus(isPremium: false),
    this.screenStatus = PremiumScreenStatus.initial,
    this.offerings,
    this.error,
  });

  const PremiumState.initial()
      : status = const PremiumStatus(isPremium: false),
        screenStatus = PremiumScreenStatus.initial,
        offerings = null,
        error = null;

  PremiumState copyWith({
    PremiumStatus? status,
    PremiumScreenStatus? screenStatus,
    Offerings? offerings,
    String? error,
  }) {
    return PremiumState(
      status: status ?? this.status,
      screenStatus: screenStatus ?? this.screenStatus,
      offerings: offerings ?? this.offerings,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, screenStatus, offerings, error];
}
