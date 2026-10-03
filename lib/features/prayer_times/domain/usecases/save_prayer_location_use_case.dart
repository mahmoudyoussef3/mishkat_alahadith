import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/prayer_location.dart';
import '../repos/prayer_times_repo.dart';

class SavePrayerLocationUseCase {
  final PrayerTimesRepo _repo;

  SavePrayerLocationUseCase(this._repo);

  Future<ApiResult<void>> call(PrayerLocation location) =>
      _repo.saveLocation(location);
}
