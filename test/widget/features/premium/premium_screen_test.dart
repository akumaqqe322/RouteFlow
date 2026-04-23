import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_event.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_state.dart';
import 'package:route_flow/features/premium/presentation/screens/premium_screen.dart';
import '../../../helpers/pump_app.dart';

class MockPremiumBloc extends MockBloc<PremiumEvent, PremiumState> implements PremiumBloc {}

void main() {
  late PremiumBloc premiumBloc;

  setUp(() {
    premiumBloc = MockPremiumBloc();
  });

  group('PremiumScreen Widget Test', () {
    testWidgets('should display setup unavailable message when config is missing', (tester) async {
      when(() => premiumBloc.state).thenReturn(
        const PremiumState(
          error: 'premium_config_missing',
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: premiumBloc,
          child: const PremiumScreen(),
        ),
      );

      expect(find.byIcon(Icons.settings_applications), findsOneWidget);
    });
  });
}
