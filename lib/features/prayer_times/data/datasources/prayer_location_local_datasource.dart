import 'package:mishkat_almasabih/core/prayer/prayer_location_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class PrayerLocationLocalDataSource {
  Future<LocationModel?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final json = PrayerLocationStore.read(prefs);
    return json == null ? null : LocationModel.fromJson(json);
  }

  Future<void> saveLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await PrayerLocationStore.write(
      prefs,
      location.toJson(),
      includeLegacyKey: true,
    );
  }
}
