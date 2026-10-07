import 'package:shared_preferences/shared_preferences.dart';

class ReadAloudSettingsLocalDataSource {
  static const String _settingsKey = 'read_aloud_settings';

  Future<String?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_settingsKey);
  }

  Future<void> saveSettings(String settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings);
  }
}
