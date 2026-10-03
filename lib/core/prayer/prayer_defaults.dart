abstract final class PrayerDefaults {
  static const double latitude = 30.0444;
  static const double longitude = 31.2357;
  static const String cityName = 'القاهرة، مصر';
}

abstract final class PrayerNames {
  static const String fajr = 'الفجر';
  static const String sunrise = 'الشروق';
  static const String dhuhr = 'الظهر';
  static const String asr = 'العصر';
  static const String maghrib = 'المغرب';
  static const String isha = 'العشاء';

  static String? arabic(String? key) => switch (key) {
    'fajr' => fajr,
    'sunrise' => sunrise,
    'dhuhr' => dhuhr,
    'asr' => asr,
    'maghrib' => maghrib,
    'isha' => isha,
    _ => null,
  };
}
