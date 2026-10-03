import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_times_calculator.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/datasources/device_location_datasource.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/datasources/prayer_location_local_datasource.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/repos/prayer_times_repo_impl.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_location.dart';

class _BrokenCalculator extends PrayerTimesCalculator {
  const _BrokenCalculator();

  @override
  PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) => throw StateError('calculation failed');
}

class _UnusedLocalDataSource extends Fake
    implements PrayerLocationLocalDataSource {}

class _UnusedDeviceLocation extends Fake implements DeviceLocationDataSource {}

PrayerTimesRepoImpl _repo(PrayerTimesCalculator calculator) =>
    PrayerTimesRepoImpl(
      _UnusedLocalDataSource(),
      calculator,
      _UnusedDeviceLocation(),
    );

void main() {
  final date = DateTime(2026, 3, 1);

  test('calculates the day\'s prayer times for a location', () {
    final result = _repo(
      const PrayerTimesCalculator(),
    ).calculatePrayerTimes(PrayerLocation.defaultLocation, date);

    final times = (result as ApiSuccess).data;
    expect(times.fajr.isBefore(times.isha), isTrue);
  });

  test('a calculation error becomes a failure instead of throwing', () {
    final result = _repo(
      const _BrokenCalculator(),
    ).calculatePrayerTimes(PrayerLocation.defaultLocation, date);

    expect((result as ApiFailure).failure, isA<UnexpectedFailure>());
  });
}
