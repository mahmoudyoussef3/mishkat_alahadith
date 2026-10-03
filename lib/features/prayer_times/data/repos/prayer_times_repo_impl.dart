import 'package:flutter/foundation.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/services/prayer_times_home_widget_sync.dart';

import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/entities/device_location.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/repos/prayer_times_repo.dart';
import '../datasources/device_location_datasource.dart';
import '../datasources/prayer_location_local_datasource.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_times_calculator.dart';
import '../mappers/prayer_times_mapper.dart';

class PrayerTimesRepoImpl implements PrayerTimesRepo {
  final PrayerLocationLocalDataSource _localDataSource;
  final PrayerTimesCalculator _calculator;
  final DeviceLocationDataSource _deviceLocation;

  PrayerTimesRepoImpl(
    this._localDataSource,
    this._calculator,
    this._deviceLocation,
  );

  @override
  Future<PrayerLocation> getSavedLocation() async {
    try {
      final saved = await _localDataSource.getLocation();
      return saved?.toEntity() ?? PrayerLocation.defaultLocation;
    } catch (e) {
      debugPrint('Error loading saved prayer location: $e');
      return PrayerLocation.defaultLocation;
    }
  }

  @override
  Future<ApiResult<void>> saveLocation(PrayerLocation location) =>
      guardApiCall(() => _localDataSource.saveLocation(location.toModel()));

  @override
  ApiResult<DailyPrayerTimes> calculatePrayerTimes(
    PrayerLocation location,
    DateTime date,
  ) {
    try {
      return ApiResult.success(
        _calculator
            .calculate(
              latitude: location.latitude,
              longitude: location.longitude,
              date: date,
            )
            .toEntity(),
      );
    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
      return ApiResult.failure(ErrorHandler.toFailure(e));
    }
  }

  @override
  Future<ApiResult<LocationAccess>> requestLocationAccess() =>
      guardApiCall(_deviceLocation.requestAccess);

  @override
  Future<ApiResult<DevicePosition>> getCurrentPosition() =>
      guardApiCall(_deviceLocation.getCurrentPosition);

  @override
  Future<void> refreshHomeWidget() => PrayerTimesHomeWidgetSync.refresh();
}
