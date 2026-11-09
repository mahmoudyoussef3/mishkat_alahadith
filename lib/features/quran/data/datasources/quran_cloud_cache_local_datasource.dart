import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_cloud_models.dart';

/// What the online Quran service sent that is worth keeping on the device:
/// the edition lists, so the pickers open offline, and the hizb index,
/// which never changes.
class QuranCloudCacheLocalDataSource {
  static const String _editionsPrefix = 'quran_cloud_editions_';
  static const String _savedAtSuffix = '_saved_at';
  static const String _hizbStartsKey = 'quran_cloud_hizb_quarter_starts';

  final Future<SharedPreferences> Function() _prefs;

  QuranCloudCacheLocalDataSource({Future<SharedPreferences> Function()? prefs})
    : _prefs = prefs ?? SharedPreferences.getInstance;

  /// The editions saved under [key], and when; null when none were saved or
  /// what was saved cannot be read.
  Future<({List<QuranEditionModel> editions, DateTime savedAt})?> getEditions(
    String key,
  ) async {
    final prefs = await _prefs();
    final raw = prefs.getString('$_editionsPrefix$key');
    final savedAt = prefs.getInt('$_editionsPrefix$key$_savedAtSuffix');
    if (raw == null || savedAt == null) return null;
    final decoded = _tryDecode(raw);
    if (decoded is! List) return null;
    final editions = [
      for (final entry in decoded)
        if (QuranEditionModel.tryFromJson(entry) case final edition?) edition,
    ];
    if (editions.isEmpty) return null;
    return (
      editions: editions,
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
  }

  Future<void> saveEditions(
    String key,
    List<QuranEditionModel> editions, {
    required DateTime savedAt,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(
      '$_editionsPrefix$key',
      jsonEncode([for (final e in editions) e.toJson()]),
    );
    await prefs.setInt(
      '$_editionsPrefix$key$_savedAtSuffix',
      savedAt.millisecondsSinceEpoch,
    );
  }

  /// Null when none were saved or what was saved cannot be read.
  Future<List<({int surah, int ayah})>?> getHizbQuarterStarts() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_hizbStartsKey);
    if (raw == null) return null;
    final decoded = _tryDecode(raw);
    if (decoded is! List) return null;
    final starts = <({int surah, int ayah})>[];
    for (final entry in decoded) {
      if (entry case [final int surah, final int ayah]) {
        starts.add((surah: surah, ayah: ayah));
      } else {
        return null;
      }
    }
    return starts;
  }

  Future<void> saveHizbQuarterStarts(
    List<({int surah, int ayah})> starts,
  ) async {
    final prefs = await _prefs();
    await prefs.setString(
      _hizbStartsKey,
      jsonEncode([
        for (final start in starts) [start.surah, start.ayah],
      ]),
    );
  }

  static Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
