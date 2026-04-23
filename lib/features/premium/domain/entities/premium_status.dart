import 'package:equatable/equatable.dart';

class PremiumStatus extends Equatable {
  final bool isPremium;
  final DateTime? expirationDate;

  const PremiumStatus({
    required this.isPremium,
    this.expirationDate,
  });

  factory PremiumStatus.free() => const PremiumStatus(isPremium: false);

  @override
  List<Object?> get props => [isPremium, expirationDate];
}
