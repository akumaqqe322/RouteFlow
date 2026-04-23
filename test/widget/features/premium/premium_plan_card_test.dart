import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/features/premium/presentation/widgets/premium_plan_card.dart';
import '../../../helpers/pump_app.dart';

class MockPackage extends Mock implements Package {}
class MockStoreProduct extends Mock implements StoreProduct {}

void main() {
  late MockPackage package;
  late MockStoreProduct product;

  setUp(() {
    package = MockPackage();
    product = MockStoreProduct();
    
    when(() => package.storeProduct).thenReturn(product);
    when(() => product.title).thenReturn('Annual Premium');
    when(() => product.description).thenReturn('Unlimited routes and discovered places');
    when(() => product.priceString).thenReturn('$19.99');
  });

  group('PremiumPlanCard Widget Test', () {
    testWidgets('should display package details', (tester) async {
      await tester.pumpApp(
        PremiumPlanCard(
          package: package,
          isSelected: false,
          onTap: () {},
        ),
      );

      expect(find.text('Annual Premium'), findsOneWidget);
      expect(find.text('$19.99'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        PremiumPlanCard(
          package: package,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(PremiumPlanCard));
      expect(tapped, isTrue);
    });
  });

  group('PremiumPlanCard Golden Test', () {
    testGoldens('should match golden for selected and unselected state', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Unselected Plan',
          PremiumPlanCard(
            package: package,
            isSelected: false,
            onTap: () {},
          ),
        )
        ..addScenario(
          'Selected Plan',
          PremiumPlanCard(
            package: package,
            isSelected: true,
            onTap: () {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData(primarySwatch: Colors.green),
          home: Scaffold(body: Center(child: child)),
        ),
      );
      
      await screenMatchesGolden(tester, 'premium_plan_card');
    });
  });
}
