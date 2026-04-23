import 'package:flutter_test/flutter_test.dart';
import 'package:route_flow/features/premium/domain/logic/premium_policy.dart';

void main() {
  group('PremiumPolicy', () {
    test('should allow saving more routes for premium users regardless of count', () {
      final canSave = PremiumPolicy.canSaveMoreRoutes(
        isPremium: true,
        currentRoutesCount: 100,
      );
      expect(canSave, isTrue);
    });

    test('should allow saving more routes for free users below limit (3)', () {
      final canSave = PremiumPolicy.canSaveMoreRoutes(
        isPremium: false,
        currentRoutesCount: 2,
      );
      expect(canSave, isTrue);
    });

    test('should deny saving more routes for free users at limit (3)', () {
      final canSave = PremiumPolicy.canSaveMoreRoutes(
        isPremium: false,
        currentRoutesCount: 3,
      );
      expect(canSave, isFalse);
    });

    test('should deny saving more routes for free users above limit (3)', () {
      final canSave = PremiumPolicy.canSaveMoreRoutes(
        isPremium: false,
        currentRoutesCount: 4,
      );
      expect(canSave, isFalse);
    });
  });
}
