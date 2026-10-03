import '../repos/prayer_times_repo.dart';

class RefreshPrayerHomeWidgetUseCase {
  final PrayerTimesRepo _repo;

  RefreshPrayerHomeWidgetUseCase(this._repo);

  Future<void> call() => _repo.refreshHomeWidget();
}
