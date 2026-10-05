import 'package:shared_preferences/shared_preferences.dart';

class ReadingPreferencesLocalDataSource {
  static const String _hadithFontScaleKey = 'hadith_font_scale';

  Future<String?> getHadithFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hadithFontScaleKey);
  }

  Future<void> saveHadithFontScale(String scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hadithFontScaleKey, scale);
  }
}
