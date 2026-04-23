import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:route_flow/features/saved_routes/domain/entities/saved_route.dart';
import 'package:route_flow/features/saved_routes/presentation/widgets/route_card.dart';
import '../../../helpers/pump_app.dart';

void main() {
  final testRoute = SavedRoute(
    id: '1',
    title: 'Morning Run',
    points: [],
    distance: 5000,
    duration: 1800,
    createdAt: DateTime(2024, 1, 1, 10, 30),
    isFavorite: false,
    startLat: 0,
    startLng: 0,
    endLat: 0,
    endLng: 0,
  );

  group('RouteCard Widget Test', () {
    testWidgets('should display route title and stats', (tester) async {
      await tester.pumpApp(
        RouteCard(
          route: testRoute,
          onTap: () {},
          onFavoriteToggle: () {},
          onRename: (_) {},
          onDelete: () {},
        ),
      );

      expect(find.text(testRoute.title), findsOneWidget);
      expect(find.byIcon(Icons.straighten), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('should call callbacks when interactions occur', (tester) async {
      bool tapped = false;
      bool favoriteToggled = false;

      await tester.pumpApp(
        RouteCard(
          route: testRoute,
          onTap: () => tapped = true,
          onFavoriteToggle: () => favoriteToggled = true,
          onRename: (_) {},
          onDelete: () {},
        ),
      );

      // Tap the card body
      await tester.tap(find.text(testRoute.title));
      expect(tapped, isTrue);

      // Tap the favorite icon
      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(favoriteToggled, isTrue);
    });
  });

  group('RouteCard Golden Test', () {
    testGoldens('should match golden for regular and favorite route', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Regular Route',
          RouteCard(
            route: testRoute,
            onTap: () {},
            onFavoriteToggle: () {},
            onRename: (_) {},
            onDelete: () {},
          ),
        )
        ..addScenario(
          'Favorite Route',
          RouteCard(
            route: testRoute.copyWith(isFavorite: true),
            onTap: () {},
            onFavoriteToggle: () {},
            onRename: (_) {},
            onDelete: () {},
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData(primarySwatch: Colors.green),
          home: Scaffold(body: Center(child: child)),
        ),
      );
      
      await screenMatchesGolden(tester, 'route_card');
    });
  });
}
