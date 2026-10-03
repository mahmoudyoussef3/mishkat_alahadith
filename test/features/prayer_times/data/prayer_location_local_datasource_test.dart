import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/datasources/prayer_location_local_datasource.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final dataSource = PrayerLocationLocalDataSource();

  test(
    'writes both keys read by the notification scheduler and home widget',
    () async {
      SharedPreferences.setMockInitialValues({});

      await dataSource.saveLocation(
        const LocationModel(
          latitude: 31.2,
          longitude: 29.9,
          cityName: 'الإسكندرية',
          timezone: '+2.0',
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('prayer_notification_location'),
        contains('الإسكندرية'),
      );
      expect(prefs.getString('prayer_location'), contains('الإسكندرية'));
    },
  );

  test('falls back to the legacy key when the new one is missing', () async {
    SharedPreferences.setMockInitialValues({
      'prayer_location':
          '{"latitude":24.08,"longitude":32.89,"cityName":"أسوان","timezone":"+2.0"}',
    });

    expect((await dataSource.getLocation())?.cityName, 'أسوان');
  });

  test('returns null when nothing is saved', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await dataSource.getLocation(), isNull);
  });
}
