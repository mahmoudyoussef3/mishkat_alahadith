import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_bookmark_model.dart';

class QuranReadingLocalDataSource {
  static const String _lastReadPageKey = 'quran_last_read_page';
  static const String _lastReadAtKey = 'quran_last_read_at';
  static const String _bookmarksKey = 'quran_bookmarks';
  static const String _tajweedKey = 'quran_tajweed_enabled';
  static const String _naturalMaddKey = 'quran_natural_madd_enabled';
  static const String _themeModeKey = 'quran_theme_mode';

  Future<({int page, int savedAtMillis})?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_lastReadPageKey);
    if (page == null) return null;
    return (page: page, savedAtMillis: prefs.getInt(_lastReadAtKey) ?? 0);
  }

  Future<void> saveLastRead({
    required int page,
    required int savedAtMillis,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadPageKey, page);
    await prefs.setInt(_lastReadAtKey, savedAtMillis);
  }

  /// Throws [FormatException] when the stored value is not a JSON list.
  Future<List<QuranBookmarkModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bookmarksKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Stored Quran bookmarks are not a list');
    }
    return [
      for (final entry in decoded)
        if (QuranBookmarkModel.tryFromJson(entry) case final model?) model,
    ];
  }

  Future<void> saveBookmarks(List<QuranBookmarkModel> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _bookmarksKey,
      jsonEncode([for (final b in bookmarks) b.toJson()]),
    );
  }

  Future<({bool? tajweed, bool? naturalMadd, String? themeMode})>
  getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      tajweed: prefs.getBool(_tajweedKey),
      naturalMadd: prefs.getBool(_naturalMaddKey),
      themeMode: prefs.getString(_themeModeKey),
    );
  }

  Future<void> saveSettings({
    required bool tajweed,
    required bool naturalMadd,
    required String themeMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tajweedKey, tajweed);
    await prefs.setBool(_naturalMaddKey, naturalMadd);
    await prefs.setString(_themeModeKey, themeMode);
  }
}
