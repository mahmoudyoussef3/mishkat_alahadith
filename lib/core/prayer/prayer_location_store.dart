import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract final class PrayerLocationStore {
  static const String key = 'prayer_notification_location';

  static const String legacyKey = 'prayer_location';

  static Map<String, dynamic>? read(SharedPreferences prefs) {
    final raw = prefs.getString(key) ?? prefs.getString(legacyKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static Future<void> write(
    SharedPreferences prefs,
    Map<String, dynamic> location, {
    bool includeLegacyKey = false,
  }) async {
    final json = jsonEncode(location);
    await prefs.setString(key, json);
    if (includeLegacyKey) await prefs.setString(legacyKey, json);
  }
}
