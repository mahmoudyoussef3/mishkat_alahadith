import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboarding;

  OnboardingCubit(this._completeOnboarding)
    : super(const OnboardingInProgress());

  Future<void> complete() async {
    await _completeOnboarding();
    emit(OnboardingCompleted());
  }
}
