import '../repos/prayer_notifications_repo.dart';

class OpenBatteryOptimizationSettingsUseCase {
  final PrayerNotificationsRepo _repo;

  OpenBatteryOptimizationSettingsUseCase(this._repo);

  Future<void> call() => _repo.openBatteryOptimizationSettings();
}
