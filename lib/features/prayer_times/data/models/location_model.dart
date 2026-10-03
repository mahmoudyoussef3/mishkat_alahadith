import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String timezone;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'timezone': timezone,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? PrayerDefaults.latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? PrayerDefaults.longitude,
      cityName: json['cityName'] as String? ?? PrayerDefaults.cityName,
      timezone: json['timezone'] as String? ?? '+2.0',
    );
  }

  @override
  String toString() => cityName;
}
