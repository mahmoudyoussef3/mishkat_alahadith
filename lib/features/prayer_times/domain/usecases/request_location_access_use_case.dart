import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/device_location.dart';
import '../repos/prayer_times_repo.dart';

class RequestLocationAccessUseCase {
  final PrayerTimesRepo _repo;

  RequestLocationAccessUseCase(this._repo);

  Future<ApiResult<LocationAccess>> call() => _repo.requestLocationAccess();
}
