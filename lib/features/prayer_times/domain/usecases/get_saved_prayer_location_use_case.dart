import '../entities/prayer_location.dart';
import '../repos/prayer_times_repo.dart';

class GetSavedPrayerLocationUseCase {
  final PrayerTimesRepo _repo;

  GetSavedPrayerLocationUseCase(this._repo);

  Future<PrayerLocation> call() => _repo.getSavedLocation();
}
