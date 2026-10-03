import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  static const String _themeModeKey = 'theme_mode';

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }
}
