import 'package:adhan/adhan.dart';

import '../../domain/entities/daily_prayer_times.dart';
import '../../domain/entities/prayer_location.dart';
import '../models/location_model.dart';

extension LocationModelMapper on LocationModel {
  PrayerLocation toEntity() => PrayerLocation(
    latitude: latitude,
    longitude: longitude,
    cityName: cityName,
    timezone: timezone,
  );
}

extension PrayerLocationMapper on PrayerLocation {
  LocationModel toModel() => LocationModel(
    latitude: latitude,
    longitude: longitude,
    cityName: cityName,
    timezone: timezone,
  );
}

extension AdhanPrayerTimesMapper on PrayerTimes {
  DailyPrayerTimes toEntity() => DailyPrayerTimes(
    fajr: fajr,
    sunrise: sunrise,
    dhuhr: dhuhr,
    asr: asr,
    maghrib: maghrib,
    isha: isha,
  );
}
