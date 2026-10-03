abstract class OnboardingRepo {
  Future<bool> isFirstLaunch();

  Future<void> completeOnboarding();
}
