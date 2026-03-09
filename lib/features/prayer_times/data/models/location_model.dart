class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String timezone; // e.g., "+2.0" for Egypt

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
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      cityName: json['cityName'] as String,
      timezone: json['timezone'] as String,
    );
  }

  // Default location (Cairo)
  static const LocationModel defaultLocation = LocationModel(
    latitude: 30.0444,
    longitude: 31.2357,
    cityName: 'القاهرة، مصر',
    timezone: '+2.0',
  );

  // Common Egyptian cities
  static List<LocationModel> egyptianCities = [
    const LocationModel(
      latitude: 30.0444,
      longitude: 31.2357,
      cityName: 'القاهرة',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 31.2001,
      longitude: 29.9187,
      cityName: 'الإسكندرية',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 26.8206,
      longitude: 30.8025,
      cityName: 'أسيوط',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 25.6872,
      longitude: 32.6396,
      cityName: 'الأقصر',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 24.0889,
      longitude: 32.8998,
      cityName: 'أسوان',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 31.0409,
      longitude: 31.3785,
      cityName: 'المنصورة',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 27.1809,
      longitude: 31.1837,
      cityName: 'المنيا',
      timezone: '+2.0',
    ),
    const LocationModel(
      latitude: 30.5965,
      longitude: 31.5084,
      cityName: 'بنها',
      timezone: '+2.0',
    ),
  ];

  @override
  String toString() => cityName;
}
