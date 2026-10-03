import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/daily_prayer_times.dart';
import '../entities/device_location.dart';
import '../entities/prayer_location.dart';

abstract class PrayerTimesRepo {
  Future<PrayerLocation> getSavedLocation();

  Future<ApiResult<void>> saveLocation(PrayerLocation location);

  ApiResult<DailyPrayerTimes> calculatePrayerTimes(
    PrayerLocation location,
    DateTime date,
  );

  Future<ApiResult<LocationAccess>> requestLocationAccess();

  Future<ApiResult<DevicePosition>> getCurrentPosition();

  Future<void> refreshHomeWidget();
}
