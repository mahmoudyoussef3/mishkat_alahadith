import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_bookmark_model.dart';
import '../models/recitation_resume_model.dart';

class QuranReadingLocalDataSource {
  static const String _lastReadPageKey = 'quran_last_read_page';
  static const String _lastReadAtKey = 'quran_last_read_at';
  static const String _bookmarksKey = 'quran_bookmarks';
  static const String _tajweedKey = 'quran_tajweed_enabled';
  static const String _naturalMaddKey = 'quran_natural_madd_enabled';
  static const String _themeModeKey = 'quran_theme_mode';
  static const String _layoutModeKey = 'quran_layout_mode';
  static const String _fontScaleKey = 'quran_font_scale';
  static const String _reciterKey = 'quran_reciter';
  static const String _reciterNameKey = 'quran_reciter_name';
  static const String _ayahRepeatKey = 'quran_ayah_repeat';
  static const String _recitationSpeedKey = 'quran_recitation_speed';
  static const String _recitationQualityKey = 'quran_recitation_quality';
  static const String _continuousKey = 'quran_recitation_continuous';
  static const String _tafsirKey = 'quran_tafsir';
  static const String _translationKey = 'quran_translation';
  static const String _recitationResumeKey = 'quran_recitation_resume';

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

  Future<
    ({
      bool? tajweed,
      bool? naturalMadd,
      String? themeMode,
      String? layoutMode,
      String? fontScale,
    })
  >
  getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      tajweed: prefs.getBool(_tajweedKey),
      naturalMadd: prefs.getBool(_naturalMaddKey),
      themeMode: prefs.getString(_themeModeKey),
      layoutMode: prefs.getString(_layoutModeKey),
      fontScale: prefs.getString(_fontScaleKey),
    );
  }

  Future<void> saveSettings({
    required bool tajweed,
    required bool naturalMadd,
    required String themeMode,
    required String layoutMode,
    required String fontScale,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tajweedKey, tajweed);
    await prefs.setBool(_naturalMaddKey, naturalMadd);
    await prefs.setString(_themeModeKey, themeMode);
    await prefs.setString(_layoutModeKey, layoutMode);
    await prefs.setString(_fontScaleKey, fontScale);
  }

  Future<
    ({
      String? reciter,
      String? reciterName,
      String? repeat,
      String? speed,
      String? quality,
      bool? continuous,
    })
  >
  getRecitationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      reciter: prefs.getString(_reciterKey),
      reciterName: prefs.getString(_reciterNameKey),
      repeat: prefs.getString(_ayahRepeatKey),
      speed: prefs.getString(_recitationSpeedKey),
      quality: prefs.getString(_recitationQualityKey),
      continuous: prefs.getBool(_continuousKey),
    );
  }

  Future<void> saveRecitationSettings({
    required String reciter,
    required String reciterName,
    required String repeat,
    required String speed,
    required String quality,
    required bool continuous,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciter);
    await prefs.setString(_reciterNameKey, reciterName);
    await prefs.setString(_ayahRepeatKey, repeat);
    await prefs.setString(_recitationSpeedKey, speed);
    await prefs.setString(_recitationQualityKey, quality);
    await prefs.setBool(_continuousKey, continuous);
  }

  Future<({String? tafsir, String? translation})>
  getCommentarySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      tafsir: prefs.getString(_tafsirKey),
      translation: prefs.getString(_translationKey),
    );
  }

  /// A null [translation] switches the translation off.
  Future<void> saveCommentarySettings({
    required String tafsir,
    required String? translation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tafsirKey, tafsir);
    if (translation == null) {
      await prefs.remove(_translationKey);
    } else {
      await prefs.setString(_translationKey, translation);
    }
  }

  /// Null when nothing was left off, or the stored entry is damaged.
  /// Throws [FormatException] when the stored value is not JSON.
  Future<RecitationResumeModel?> getRecitationResume() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recitationResumeKey);
    if (raw == null || raw.isEmpty) return null;
    return RecitationResumeModel.tryFromJson(jsonDecode(raw));
  }

  /// A null [resume] forgets the one kept.
  Future<void> saveRecitationResume(RecitationResumeModel? resume) async {
    final prefs = await SharedPreferences.getInstance();
    if (resume == null) {
      await prefs.remove(_recitationResumeKey);
    } else {
      await prefs.setString(_recitationResumeKey, jsonEncode(resume.toJson()));
    }
  }
}
