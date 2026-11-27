import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenericCacheService {
  static const int _defaultCacheExpirationHours = 100;

  /// How much is kept, oldest save out first. Expired entries are kept for
  /// offline use, so nothing else ever removes them, and SharedPreferences
  /// is read whole into memory at launch: an unbounded cache would slow
  /// every start.
  static const int defaultMaxEntries = 400;
  static const int defaultMaxChars = 1200000;
  static const String _indexKey = 'generic_cache_index';

  static GenericCacheService? _instance;
  static GenericCacheService get instance =>
      _instance ??= GenericCacheService._();
  GenericCacheService._()
    : maxEntries = defaultMaxEntries,
      maxChars = defaultMaxChars;

  @visibleForTesting
  GenericCacheService.withLimits({
    required this.maxEntries,
    required this.maxChars,
  });

  final int maxEntries;

  /// Summed over the stored JSON strings.
  final int maxChars;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> saveData<T>({
    required String key,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
    int cacheExpirationHours = _defaultCacheExpirationHours,
  }) async {
    try {
      await init();

      final jsonString = jsonEncode(toJson(data));
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final dataKey = '${key}_data';
      final timestampKey = '${key}_timestamp';
      final expirationKey = '${key}_expiration';

      final dataResult = await _prefs!.setString(dataKey, jsonString);
      final timestampResult = await _prefs!.setInt(timestampKey, timestamp);
      final expirationResult = await _prefs!.setInt(
        expirationKey,
        cacheExpirationHours,
      );

      await _remember(key);

      log(
        '✅ Data cached successfully for key "$key": $dataResult && $timestampResult && $expirationResult',
      );
      return dataResult && timestampResult && expirationResult;
    } catch (e) {
      log('❌ Error caching data for key "$key": $e');
      return false;
    }
  }

  /// Marks [key] as the newest entry and forgets the oldest ones past
  /// [maxEntries] or [maxChars]; [key] itself is always kept. The index is
  /// read and replaced with no await in between, so saves running at the
  /// same time cannot drop each other from it and escape the bound.
  Future<void> _remember(String key) async {
    final prefs = _prefs!;
    int sizeOf(String k) => prefs.getString('${k}_data')?.length ?? 0;

    final index = [
      for (final kept in prefs.getStringList(_indexKey) ?? const <String>[])
        if (kept != key) kept,
      key,
    ];
    var chars = index.fold<int>(0, (sum, k) => sum + sizeOf(k));
    final evicted = <String>[];
    while (index.length > 1 &&
        (index.length > maxEntries || chars > maxChars)) {
      final oldest = index.removeAt(0);
      chars -= sizeOf(oldest);
      evicted.add(oldest);
    }
    final indexSaved = prefs.setStringList(_indexKey, index);
    try {
      for (final oldest in evicted) {
        await _removeEntry(oldest);
        log('🧹 Cache entry "$oldest" evicted to stay within bounds');
      }
    } finally {
      await indexSaved;
    }
  }

  Future<List<bool>> _removeEntry(String key) => Future.wait([
    _prefs!.remove('${key}_data'),
    _prefs!.remove('${key}_timestamp'),
    _prefs!.remove('${key}_expiration'),
  ]);

  /// The data saved under [key], or null when there is none or it has
  /// expired. With [allowStale], expired data is returned too: offline, an
  /// old copy beats an empty screen.
  Future<T?> getData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    bool allowStale = false,
  }) async {
    try {
      await init();

      if (!allowStale && !await _isCacheValid(key)) {
        log('📅 Cache expired or invalid for key "$key"');
        return null;
      }

      final dataKey = '${key}_data';
      final jsonString = _prefs!.getString(dataKey);
      if (jsonString == null) {
        log('❌ No cached data found for key "$key"');
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = fromJson(jsonMap);

      log('✅ Data loaded from cache for key "$key"');
      return data;
    } catch (e) {
      log('❌ Error loading cached data for key "$key": $e');
      await clearCache(key);
      return null;
    }
  }

  Future<bool> _isCacheValid(String key) async {
    await init();

    final timestampKey = '${key}_timestamp';
    final expirationKey = '${key}_expiration';

    final timestamp = _prefs!.getInt(timestampKey);
    final expirationHours =
        _prefs!.getInt(expirationKey) ?? _defaultCacheExpirationHours;

    if (timestamp == null) return false;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime);

    return difference.inHours < expirationHours;
  }

  Future<bool> clearCache(String key) async {
    try {
      await init();

      final index = _prefs!.getStringList(_indexKey);
      final indexSaved =
          index != null && index.contains(key)
              ? _prefs!.setStringList(_indexKey, [
                for (final kept in index)
                  if (kept != key) kept,
              ])
              : null;

      final [result1, result2, result3] = await _removeEntry(key);
      await indexSaved;

      log('🗑️ Cache cleared for key "$key": $result1 && $result2 && $result3');
      return result1 && result2 && result3;
    } catch (e) {
      log('❌ Error clearing cache for key "$key": $e');
      return false;
    }
  }

  Future<bool> clearAllCache() async {
    try {
      await init();
      final result = await _prefs!.clear();
      log('🗑️ All cache cleared: $result');
      return result;
    } catch (e) {
      log('❌ Error clearing all cache: $e');
      return false;
    }
  }

  Future<bool> hasCache(String key) async {
    await init();
    final dataKey = '${key}_data';
    return _prefs!.containsKey(dataKey);
  }

  Future<bool> isCacheValid(String key) async {
    return await _isCacheValid(key);
  }

  Future<Map<String, dynamic>> getCacheInfo(String key) async {
    await init();

    final timestampKey = '${key}_timestamp';
    final expirationKey = '${key}_expiration';
    final dataKey = '${key}_data';

    final timestamp = _prefs!.getInt(timestampKey);
    final expiration = _prefs!.getInt(expirationKey);

    return {
      'exists': _prefs!.containsKey(dataKey),
      'valid': await _isCacheValid(key),
      'timestamp':
          timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString()
              : null,
      'expiration_hours': expiration,
    };
  }

  Future<List<String>> getAllCachedKeys() async {
    await init();
    final allKeys = _prefs!.getKeys();
    final cacheKeys = <String>{};

    for (final key in allKeys) {
      if (key.endsWith('_data')) {
        cacheKeys.add(key.substring(0, key.length - 5));
      }
    }

    return cacheKeys.toList();
  }

  Future<bool> forceRefresh(String key) async {
    final result = await clearCache(key);
    log('🔄 Force refresh for key "$key" - cache cleared: $result');
    return result;
  }

  Future<int> getCacheSize() async {
    await init();
    int totalSize = 0;

    final keys = _prefs!.getKeys();
    for (final key in keys) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length * 2;
      } else if (value is int) {
        totalSize += 8;
      } else if (value is bool) {
        totalSize += 1;
      } else if (value is double) {
        totalSize += 8;
      }
    }

    return totalSize;
  }

  Future<int> cleanupExpiredCache() async {
    await init();
    int cleanedCount = 0;

    final cachedKeys = await getAllCachedKeys();
    for (final key in cachedKeys) {
      if (!await _isCacheValid(key)) {
        await clearCache(key);
        cleanedCount++;
        log('🧹 Cleaned expired cache for key: $key');
      }
    }

    log('🧹 Cleanup completed. Removed $cleanedCount expired cache entries');
    return cleanedCount;
  }
}

class CacheKeys {
  static const String libraryStatistics = 'library_statistics';
  static const String userProfile = 'user_profile';
  static const String userStats = 'user_stats';
  static const String bookmarks = 'bookmarks';
  static const String bookmarkCollections = 'bookmark_collections';

  static const String hadithCategories = 'hadith_categories_v2';
  static const String randomAhadith = 'random_ahadith';
  static const String searchHistory = 'search_history';

  static String paginatedAhadith(String bookSlug, int chapterId) =>
      'ahadith_${bookSlug}_$chapterId';

  static String localAhadith(String bookSlug, int chapterId) =>
      'local_ahadith_${bookSlug}_$chapterId';

  static String arbainAhadith(String bookSlug, int chapterId) =>
      'arbain_ahadith_${bookSlug}_$chapterId';

  static String chapters(String bookSlug) => 'chapters_$bookSlug';

  static String bookData(String categoryId) => 'book_data_$categoryId';

  static String navigation(
    String bookSlug,
    int chapterNumber,
    String hadithNumber,
  ) => 'nav_${bookSlug}_${chapterNumber}_$hadithNumber';

  static String localNavigation(String bookSlug, String hadithNumber) =>
      'local_nav_${bookSlug}_$hadithNumber';

  static String enhancedSearch(String query) =>
      'enhanced_search_${query.hashCode}';

  static String searchWithFilters(
    String query,
    String? bookSlug,
    String narrator,
    String grade,
    String chapter,
    String category,
  ) {
    final filters = '${bookSlug ?? 'all'}_${narrator}_${grade}_${chapter}_$category';
    return 'search_filtered_${query.hashCode}_${filters.hashCode}';
  }

  static String ahadithByCategory(String categoryId, int page, int perPage) =>
      'ahadith_by_category_${categoryId}_${page}_$perPage';

  static String hadithDetails(String id) => 'hadith_details_$id';

  static String hadithAnalysis(
    String hadith,
    String attribution,
    String grade,
    String reference,
  ) {
    // The length alongside the hash makes two hadiths sharing a key far
    // less likely than the hash alone would.
    final request = '$hadith|$attribution|$grade|$reference';
    return 'hadith_analysis_${request.length}_${request.hashCode}';
  }
}
