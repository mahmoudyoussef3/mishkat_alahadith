import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, per book, which chapter was opened last.
class ChaptersProgressLocalDataSource {
  static String _key(String bookSlug) => 'last_read_chapter_$bookSlug';

  Future<Map<String, dynamic>?> getLastReadChapter(String bookSlug) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(bookSlug));
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> saveLastReadChapter(
    String bookSlug,
    Map<String, dynamic> chapter,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(bookSlug), jsonEncode(chapter));
  }
}
