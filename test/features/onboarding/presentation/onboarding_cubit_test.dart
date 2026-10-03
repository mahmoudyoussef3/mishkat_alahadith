import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/repos/onboarding_repo.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:mishkat_almasabih/features/onboarding/presentation/logic/onboarding_cubit.dart';

class _FakeOnboardingRepo implements OnboardingRepo {
  int completions = 0;

  @override
  Future<void> completeOnboarding() async => completions++;

  @override
  Future<bool> isFirstLaunch() async => true;
}

void main() {
  test('emits OnboardingCompleted on every tap so the listener navigates each time', () async {
    final repo = _FakeOnboardingRepo();
    final cubit = OnboardingCubit(CompleteOnboardingUseCase(repo));
    final emitted = <OnboardingState>[];
    final sub = cubit.stream.listen(emitted.add);

    await cubit.complete();
    // The user comes back from the login screen and taps "Get Started" again.
    await cubit.complete();
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [isA<OnboardingCompleted>(), isA<OnboardingCompleted>()]);
    expect(repo.completions, 2);

    await sub.cancel();
    await cubit.close();
  });
}
