import '../repos/onboarding_repo.dart';

class IsFirstLaunchUseCase {
  final OnboardingRepo _repo;

  IsFirstLaunchUseCase(this._repo);

  Future<bool> call() => _repo.isFirstLaunch();
}
