import '../entities/daily_prayer_times.dart';

/// The most recent prayer at or before [now], so the time until the next
/// one can be shown as progress. Before today's Fajr that is last night's
/// Isha, taken as today's Isha a day earlier (they differ by a minute or
/// two at most).
class GetPreviousPrayerUseCase {
  NextPrayer call({required DailyPrayerTimes today, required DateTime now}) {
    final prayers = [
      ('isha', today.isha),
      ('maghrib', today.maghrib),
      ('asr', today.asr),
      ('dhuhr', today.dhuhr),
      ('fajr', today.fajr),
    ];

    for (final (key, time) in prayers) {
      if (!time.isAfter(now)) return NextPrayer(key: key, time: time);
    }
    return NextPrayer(
      key: 'isha',
      time: today.isha.subtract(const Duration(days: 1)),
    );
  }
}
