import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';

class PrayerLocation {
  final double latitude;
  final double longitude;
  final String cityName;
  final String timezone;

  const PrayerLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.timezone,
  });

  factory PrayerLocation.currentDevice({
    required double latitude,
    required double longitude,
    required Duration utcOffset,
  }) {
    final hours = utcOffset.inHours;
    return PrayerLocation(
      latitude: latitude,
      longitude: longitude,
      cityName: 'موقعك الحالي',
      timezone: hours >= 0 ? '+$hours.0' : '$hours.0',
    );
  }

  static const PrayerLocation defaultLocation = PrayerLocation(
    latitude: PrayerDefaults.latitude,
    longitude: PrayerDefaults.longitude,
    cityName: PrayerDefaults.cityName,
    timezone: '+2.0',
  );

  static const List<PrayerLocation> egyptianCities = [
    PrayerLocation(
      latitude: 30.0444,
      longitude: 31.2357,
      cityName: 'القاهرة',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 31.2001,
      longitude: 29.9187,
      cityName: 'الإسكندرية',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 26.8206,
      longitude: 30.8025,
      cityName: 'أسيوط',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 25.6872,
      longitude: 32.6396,
      cityName: 'الأقصر',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 24.0889,
      longitude: 32.8998,
      cityName: 'أسوان',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 31.0409,
      longitude: 31.3785,
      cityName: 'المنصورة',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 27.1809,
      longitude: 31.1837,
      cityName: 'المنيا',
      timezone: '+2.0',
    ),
    PrayerLocation(
      latitude: 30.5965,
      longitude: 31.5084,
      cityName: 'بنها',
      timezone: '+2.0',
    ),
  ];

  @override
  String toString() => cityName;
}
