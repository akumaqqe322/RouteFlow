import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:route_flow/features/premium/domain/entities/premium_status.dart';
import 'package:route_flow/features/premium/domain/repositories/premium_repository.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_event.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_state.dart';
import 'package:route_flow/core/error/premium_failure.dart';

class MockPremiumRepository extends Mock implements PremiumRepository {}

void main() {
  late PremiumRepository repository;
  late PremiumBloc bloc;

  setUp(() {
    repository = MockPremiumRepository();
    bloc = PremiumBloc(repository);
  });

  group('PremiumBloc Config Failure', () {
    blocTest<PremiumBloc, PremiumState>(
      'emits state with error when initialization fails due to missing config',
      build: () {
        when(() => repository.initialize(any())).thenThrow(const PremiumConfigurationFailure());
        return bloc;
      },
      act: (bloc) => bloc.add(const InitializePremium('user123')),
      expect: () => [
        PremiumState.initial().copyWith(error: 'premium_config_missing'),
      ],
    );
  });
}
