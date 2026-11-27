import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran_cloud_models.dart';

/// What the online Quran service sent that is worth keeping on the device:
/// the edition lists, so the pickers open offline, the hizb index, which
/// never changes, and the last answers to text requests (tafsir,
/// translations, searches), so what was read once reads again offline.
class QuranCloudCacheLocalDataSource {
  /// Text answers kept at most; each tafsir passage is its own answer, so
  /// without a bound the store would grow with every ayah opened.
  static const int maxResponses = 300;

  /// Text kept at most, summed over the answers: a long tafsir runs to
  /// hundreds of thousands of characters, and SharedPreferences is read
  /// whole into memory at launch.
  static const int maxResponseChars = 400000;

  static const String _editionsPrefix = 'quran_cloud_editions_';
  static const String _savedAtSuffix = '_saved_at';
  static const String _hizbStartsKey = 'quran_cloud_hizb_quarter_starts';
  static const String _responsePrefix = 'quran_cloud_response_';
  static const String _responseIndexKey = 'quran_cloud_response_index';

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

  /// The answer saved under [key]; null when none was saved or what was
  /// saved cannot be read.
  Future<Object?> getResponse(String key) async {
    final prefs = await _prefs();
    final raw = prefs.getString('$_responsePrefix$key');
    return raw == null ? null : _tryDecode(raw);
  }

  /// Keeps [json] under [key] as the newest answer, forgetting the oldest
  /// once more than [maxResponses] are kept or they add up to more than
  /// [maxResponseChars]; [key] itself is always kept.
  Future<void> saveResponse(String key, Object? json) async {
    final prefs = await _prefs();
    final encoded = jsonEncode(json);
    int sizeOf(String k) =>
        k == key
            ? encoded.length
            : prefs.getString('$_responsePrefix$k')?.length ?? 0;

    final index = <String>[
      for (final kept in prefs.getStringList(_responseIndexKey) ?? const [])
        if (kept != key) kept,
      key,
    ];
    var chars = index.fold<int>(0, (sum, k) => sum + sizeOf(k));
    final evicted = <String>[];
    while (index.length > 1 &&
        (index.length > maxResponses || chars > maxResponseChars)) {
      final oldest = index.removeAt(0);
      chars -= sizeOf(oldest);
      evicted.add(oldest);
    }
    // The index is read and replaced with no await in between, so answers
    // saved at the same time cannot drop each other from it and escape the
    // bound.
    final indexSaved = prefs.setStringList(_responseIndexKey, index);
    try {
      for (final oldest in evicted) {
        await prefs.remove('$_responsePrefix$oldest');
      }
      await prefs.setString('$_responsePrefix$key', encoded);
    } finally {
      await indexSaved;
    }
  }

  static Object? _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
