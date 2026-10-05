import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_previous_prayer_use_case.dart';

final _today = DailyPrayerTimes(
  fajr: DateTime(2026, 10, 5, 4, 24),
  sunrise: DateTime(2026, 10, 5, 5, 49),
  dhuhr: DateTime(2026, 10, 5, 11, 43),
  asr: DateTime(2026, 10, 5, 15, 7),
  maghrib: DateTime(2026, 10, 5, 17, 37),
  isha: DateTime(2026, 10, 5, 18, 54),
);

void main() {
  final previous = GetPreviousPrayerUseCase();

  test('is the last prayer already prayed today', () {
    final prayer = previous(today: _today, now: DateTime(2026, 10, 5, 14, 25));

    expect(prayer.key, 'dhuhr');
    expect(prayer.time, _today.dhuhr);
  });

  test('skips sunrise between Fajr and Dhuhr', () {
    expect(previous(today: _today, now: DateTime(2026, 10, 5, 9)).key, 'fajr');
  });

  test('counts a prayer whose time is exactly now', () {
    expect(previous(today: _today, now: _today.asr).key, 'asr');
  });

  test('is last night\'s Isha before Fajr', () {
    final prayer = previous(today: _today, now: DateTime(2026, 10, 5, 3));

    expect(prayer.key, 'isha');
    expect(prayer.time, DateTime(2026, 10, 4, 18, 54));
  });
}
