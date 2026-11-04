import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/azkar_progress_model.dart';

class AzkarPreferencesLocalDataSource {
  static const String _favoritesKey = 'azkar_favorites';
  static const String _progressKey = 'azkar_progress';
  static const String _translationKey = 'azkar_translation';
  static const String _fontScaleKey = 'azkar_font_scale';
  static const String _hapticsKey = 'azkar_haptics';
  static const String _autoAdvanceKey = 'azkar_auto_advance';

  Future<List<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      for (final id in prefs.getStringList(_favoritesKey) ?? const <String>[])
        if (int.tryParse(id) case final parsed?) parsed,
    ];
  }

  Future<void> saveFavoriteIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, [for (final id in ids) '$id']);
  }

  /// Null before anything is counted, or when the stored entry has no day.
  /// Throws [FormatException] when the stored value is not JSON.
  Future<AzkarProgressModel?> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return null;
    return AzkarProgressModel.tryFromJson(jsonDecode(raw));
  }

  Future<void> saveProgress(AzkarProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<
    ({
      String? translation,
      String? fontScale,
      bool? hapticFeedback,
      bool? autoAdvance,
    })
  >
  getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      translation: prefs.getString(_translationKey),
      fontScale: prefs.getString(_fontScaleKey),
      hapticFeedback: prefs.getBool(_hapticsKey),
      autoAdvance: prefs.getBool(_autoAdvanceKey),
    );
  }

  Future<void> saveSettings({
    required String translation,
    required String fontScale,
    required bool hapticFeedback,
    required bool autoAdvance,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationKey, translation);
    await prefs.setString(_fontScaleKey, fontScale);
    await prefs.setBool(_hapticsKey, hapticFeedback);
    await prefs.setBool(_autoAdvanceKey, autoAdvance);
  }
}
