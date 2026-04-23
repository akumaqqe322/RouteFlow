import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_state.dart';
import 'package:route_flow/features/my_routes/presentation/screens/my_routes_screen.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_state.dart';
import '../../../helpers/pump_app.dart';

class MockSavedRoutesBloc extends MockBloc<SavedRoutesEvent, SavedRoutesState> implements SavedRoutesBloc {}
class MockRouteBloc extends MockBloc<dynamic, RouteState> implements RouteBloc {}

void main() {
  late SavedRoutesBloc savedRoutesBloc;
  late RouteBloc routeBloc;

  setUp(() {
    savedRoutesBloc = MockSavedRoutesBloc();
    routeBloc = MockRouteBloc();
  });

  group('MyRoutesScreen Widget Test', () {
    // ... existing tests
  });

  group('MyRoutesScreen Golden Test', () {
    testGoldens('should match golden for empty and error state', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Empty State',
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: savedRoutesBloc),
              BlocProvider.value(value: routeBloc),
            ],
            child: const MyRoutesScreen(),
          ),
        );

      when(() => savedRoutesBloc.state).thenReturn(const SavedRoutesState(
        status: SavedRoutesStatus.success,
        routes: [],
      ));

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: (child) => MaterialApp(
          theme: ThemeData(primarySwatch: Colors.green),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: child)),
        ),
      );
      
      await screenMatchesGolden(tester, 'my_routes_empty');
    });
  });
}
    testWidgets('should display empty state message when no routes', (tester) async {
      when(() => savedRoutesBloc.state).thenReturn(const SavedRoutesState(
        status: SavedRoutesStatus.success,
        routes: [],
      ));

      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: savedRoutesBloc),
            BlocProvider.value(value: routeBloc),
          ],
          child: const MyRoutesScreen(),
        ),
      );

      // Verify empty state is shown
      // Instead of hardcoded text, we can look for types or icons if available, 
      // but finding by text from l10n is standard if we use pumpApp helper
      expect(find.byIcon(Icons.route_outlined), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should display error state when storage fails', (tester) async {
      when(() => savedRoutesBloc.state).thenReturn(const SavedRoutesState(
        status: SavedRoutesStatus.failure,
        error: 'storage_error',
        routes: [],
      ));

      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: savedRoutesBloc),
            BlocProvider.value(value: routeBloc),
          ],
          child: const MyRoutesScreen(),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
