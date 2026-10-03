import 'package:adhan/adhan.dart';

class PrayerTimesCalculator {
  const PrayerTimesCalculator();

  PrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    return PrayerTimes(
      Coordinates(latitude, longitude),
      DateComponents.from(date),
      params,
    );
  }
}
