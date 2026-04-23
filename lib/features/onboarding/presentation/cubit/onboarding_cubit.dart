import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingRepository _repository;

  OnboardingCubit(this._repository) : super(OnboardingInitial()) {
    _checkStatus();
  }

  void _checkStatus() {
    if (_repository.isOnboardingCompleted()) {
      emit(OnboardingComplete());
    } else {
      emit(OnboardingIncomplete());
    }
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    emit(OnboardingComplete());
  }
}
