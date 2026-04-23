import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:route_flow/features/onboarding/domain/repositories/onboarding_repository.dart';

@LazySingleton(as: OnboardingRepository)
class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  final SharedPreferences _prefs;
  static const _key = 'onboarding_completed';

  SharedPreferencesOnboardingRepository(this._prefs);

  @override
  bool isOnboardingCompleted() {
    return _prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_key, true);
  }
}
