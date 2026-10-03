import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_location_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('prefers the current key over the legacy one', () async {
    SharedPreferences.setMockInitialValues({
      PrayerLocationStore.key: '{"cityName":"المنصورة"}',
      PrayerLocationStore.legacyKey: '{"cityName":"أسوان"}',
    });
    final prefs = await SharedPreferences.getInstance();

    expect(PrayerLocationStore.read(prefs)?['cityName'], 'المنصورة');
  });

  test('treats an unparseable stored value as no location', () async {
    SharedPreferences.setMockInitialValues({PrayerLocationStore.key: '{oops'});
    final prefs = await SharedPreferences.getInstance();

    expect(PrayerLocationStore.read(prefs), isNull);
  });

  test('writes only the current key unless asked to mirror the legacy key', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await PrayerLocationStore.write(prefs, {'cityName': 'بنها'});

    expect(prefs.getString(PrayerLocationStore.key), contains('بنها'));
    expect(prefs.getString(PrayerLocationStore.legacyKey), isNull);
  });
}
