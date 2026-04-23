import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:route_flow/features/premium/domain/repositories/premium_repository.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_event.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_state.dart';

import 'package:route_flow/core/error/premium_failure.dart';

@injectable
class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final PremiumRepository _repository;

  PremiumBloc(this._repository) : super(const PremiumState.initial()) {
    on<InitializePremium>(_onInitialize);
    on<LoadPremiumOfferings>(_onLoadOfferings);
    on<PurchasePackage>(_onPurchase);
    on<RestorePurchases>(_onRestore);
  }

  Future<void> _onInitialize(
    InitializePremium event,
    Emitter<PremiumState> emit,
  ) async {
    await _repository.initialize(event.userId);
    final status = await _repository.getStatus();
    emit(state.copyWith(status: status));
  }

  Future<void> _onLoadOfferings(
    LoadPremiumOfferings event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(screenStatus: PremiumScreenStatus.loading));
    try {
      final offerings = await _repository.getOfferings();
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.success,
        offerings: offerings,
      ));
    } on PremiumFailure catch (e) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: 'offerings_load_failed',
      ));
    }
  }

  Future<void> _onPurchase(
    PurchasePackage event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(screenStatus: PremiumScreenStatus.purchasing));
    try {
      final success = await _repository.purchasePackage(event.package);
      if (success) {
        final status = await _repository.getStatus();
        emit(state.copyWith(
          status: status,
          screenStatus: PremiumScreenStatus.success,
        ));
      } else {
        emit(state.copyWith(
          screenStatus: PremiumScreenStatus.failure,
          error: 'purchase_failed',
        ));
      }
    } on PremiumFailure catch (e) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: 'purchase_failed',
      ));
    }
  }

  Future<void> _onRestore(
    RestorePurchases event,
    Emitter<PremiumState> emit,
  ) async {
    emit(state.copyWith(screenStatus: PremiumScreenStatus.purchasing));
    try {
      final status = await _repository.restorePurchases();
      emit(state.copyWith(
        status: status,
        screenStatus: PremiumScreenStatus.success,
      ));
    } on PremiumFailure catch (e) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        screenStatus: PremiumScreenStatus.failure,
        error: 'restore_failed',
      ));
    }
  }
}
