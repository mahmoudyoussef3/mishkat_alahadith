import 'dart:developer';

import '../../domain/repos/onboarding_repo.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepoImpl implements OnboardingRepo {
  final OnboardingLocalDataSource _local;

  OnboardingRepoImpl(this._local);

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return await _local.isFirstTime();
    } catch (error) {
      log('Unable to read the onboarding flag: $error');
      return true;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _local.setNotFirstTime();
    } catch (error) {
      log('Unable to save the onboarding flag: $error');
    }
  }
}
