import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:route_flow/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:route_flow/features/auth/presentation/cubit/sign_in_state.dart';
import 'package:route_flow/features/auth/presentation/screens/auth_screen.dart';
import '../../../helpers/pump_app.dart';

class MockSignInCubit extends MockCubit<SignInState> implements SignInCubit {}

void main() {
  late SignInCubit cubit;

  setUpAll(() {
    cubit = MockSignInCubit();
    // Register mock in getIt
    getIt.registerLazySingleton<SignInCubit>(() => cubit);
  });

  tearDownAll(() {
    getIt.reset();
  });

  group('AuthScreen Widget Test', () {
    testWidgets('should display login mode by default', (tester) async {
      when(() => cubit.state).thenReturn(const SignInState(isLoginMode: true));
      
      await tester.pumpApp(const AuthScreen());

      expect(find.text('Login'), findsOneWidget); // Depends on l10n
      // More specific finding by text from localized strings
    });

    testWidgets('should switch to register mode when toggle is tapped', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([
          const SignInState(isLoginMode: true),
          const SignInState(isLoginMode: false),
        ]),
        initialState: const SignInState(isLoginMode: true),
      );

      await tester.pumpApp(const AuthScreen());
      
      // Tap toggle button (text varies by locale, finding by type for robustness)
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      verify(() => cubit.toggleMode()).called(1);
    });
  });
}
