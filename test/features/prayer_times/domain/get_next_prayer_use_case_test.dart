import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_next_prayer_use_case.dart';

DailyPrayerTimes _timesOn(DateTime day) => DailyPrayerTimes(
  fajr: DateTime(day.year, day.month, day.day, 4, 30),
  sunrise: DateTime(day.year, day.month, day.day, 6),
  dhuhr: DateTime(day.year, day.month, day.day, 12),
  asr: DateTime(day.year, day.month, day.day, 15, 30),
  maghrib: DateTime(day.year, day.month, day.day, 18),
  isha: DateTime(day.year, day.month, day.day, 19, 30),
);

void main() {
  final today = _timesOn(DateTime(2026, 10, 2));
  final tomorrow = _timesOn(DateTime(2026, 10, 3));
  final getNextPrayer = GetNextPrayerUseCase();

  NextPrayer at(int hour, int minute) => getNextPrayer(
    today: today,
    tomorrow: tomorrow,
    now: DateTime(2026, 10, 2, hour, minute),
  );

  test('picks the first prayer still ahead today', () {
    expect(at(13, 0).key, 'asr');
    expect(at(4, 0).key, 'fajr');
  });

  test('skips sunrise (it is not a prayer)', () {
    expect(at(5, 0).key, 'dhuhr');
  });

  test("returns tomorrow's fajr after isha", () {
    final next = at(21, 0);

    expect(next.key, 'fajr');
    expect(next.time, DateTime(2026, 10, 3, 4, 30));
  });
}
