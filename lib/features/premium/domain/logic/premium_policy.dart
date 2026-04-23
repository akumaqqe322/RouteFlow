class PremiumPolicy {
  static const int freeSavedRoutesLimit = 3;

  static bool canSaveMoreRoutes({
    required bool isPremium,
    required int currentRoutesCount,
  }) {
    if (isPremium) return true;
    return currentRoutesCount < freeSavedRoutesLimit;
  }
}
