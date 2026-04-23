import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_state.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late OnboardingRepository repository;
  late OnboardingCubit cubit;

  setUp(() {
    repository = MockOnboardingRepository();
  });

  group('OnboardingCubit', () {
    test('initial state is OnboardingInitial', () {
      when(() => repository.isOnboardingCompleted()).thenReturn(false);
      cubit = OnboardingCubit(repository);
      expect(cubit.state, isA<OnboardingInitial>());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingIncomplete] when status is incomplete',
      build: () {
        when(() => repository.isOnboardingCompleted()).thenReturn(false);
        return OnboardingCubit(repository);
      },
      expect: () => [isA<OnboardingIncomplete>()],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingComplete] when status is complete',
      build: () {
        when(() => repository.isOnboardingCompleted()).thenReturn(true);
        return OnboardingCubit(repository);
      },
      expect: () => [isA<OnboardingComplete>()],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [OnboardingComplete] after completeOnboarding is called',
      build: () {
        when(() => repository.isOnboardingCompleted()).thenReturn(false);
        when(() => repository.completeOnboarding()).thenAnswer((_) async {});
        return OnboardingCubit(repository);
      },
      act: (cubit) => cubit.completeOnboarding(),
      expect: () => [
        isA<OnboardingIncomplete>(), // From constructor init
        isA<OnboardingComplete>(),     // From act
      ],
    );
  });
}
