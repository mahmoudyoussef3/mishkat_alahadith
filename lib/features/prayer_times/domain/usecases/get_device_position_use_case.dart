import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/device_location.dart';
import '../repos/prayer_times_repo.dart';

class GetDevicePositionUseCase {
  final PrayerTimesRepo _repo;

  GetDevicePositionUseCase(this._repo);

  Future<ApiResult<DevicePosition>> call() => _repo.getCurrentPosition();
}
