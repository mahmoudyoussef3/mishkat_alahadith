import 'package:shared_preferences/shared_preferences.dart';

class SaveDataForFirstTime {
  static const String _firstTimeKey = "isFirstTime";

  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }
}
