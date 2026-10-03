part of 'onboarding_cubit.dart';

sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress();
}

final class OnboardingCompleted extends OnboardingState {
  OnboardingCompleted();
}
