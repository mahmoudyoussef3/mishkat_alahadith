import '../entities/daily_prayer_times.dart';

class GetNextPrayerUseCase {
  NextPrayer call({
    required DailyPrayerTimes today,
    required DailyPrayerTimes tomorrow,
    required DateTime now,
  }) {
    final prayers = [
      ('fajr', today.fajr),
      ('dhuhr', today.dhuhr),
      ('asr', today.asr),
      ('maghrib', today.maghrib),
      ('isha', today.isha),
    ];

    for (final (key, time) in prayers) {
      if (time.isAfter(now)) return NextPrayer(key: key, time: time);
    }
    return NextPrayer(key: 'fajr', time: tomorrow.fajr);
  }
}
