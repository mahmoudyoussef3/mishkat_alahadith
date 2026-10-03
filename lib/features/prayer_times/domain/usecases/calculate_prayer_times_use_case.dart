import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/daily_prayer_times.dart';
import '../entities/prayer_location.dart';
import '../repos/prayer_times_repo.dart';

class CalculatePrayerTimesUseCase {
  final PrayerTimesRepo _repo;

  CalculatePrayerTimesUseCase(this._repo);

  ApiResult<DailyPrayerTimes> call(PrayerLocation location, DateTime date) =>
      _repo.calculatePrayerTimes(location, date);
}
