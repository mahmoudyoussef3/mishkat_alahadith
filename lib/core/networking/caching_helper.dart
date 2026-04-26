import 'dart:convert';
import 'dart:developer';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/hadith_daily_response.dart';
import 'package:mishkat_almasabih/features/home/data/models/book_model.dart';
import 'package:mishkat_almasabih/features/home/data/models/library_statistics_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic Cache Service that can handle any type of data
class GenericCacheService {
  static const int _defaultCacheExpirationHours = 100;

  static GenericCacheService? _instance;
  static GenericCacheService get instance =>
      _instance ??= GenericCacheService._();
  GenericCacheService._();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // =========================== GENERIC CACHE METHODS ===========================

  /// Save any data to cache with custom key and expiration
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

      log(
        '✅ Data cached successfully for key "$key": $dataResult && $timestampResult && $expirationResult',
      );
      return dataResult && timestampResult && expirationResult;
    } catch (e) {
      log('❌ Error caching data for key "$key": $e');
      return false;
    }
  }

  /// Get data from cache with custom deserializer
  Future<T?> getData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      await init();

      // Check if cache exists and is not expired
      if (!await _isCacheValid(key)) {
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
      await clearCache(key); // Clear corrupted cache
      return null;
    }
  }

  /// Check if cache is valid (not expired) for a specific key
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

  /// Clear cache for a specific key
  Future<bool> clearCache(String key) async {
    try {
      await init();

      final dataKey = '${key}_data';
      final timestampKey = '${key}_timestamp';
      final expirationKey = '${key}_expiration';

      final result1 = await _prefs!.remove(dataKey);
      final result2 = await _prefs!.remove(timestampKey);
      final result3 = await _prefs!.remove(expirationKey);

      log('🗑️ Cache cleared for key "$key": $result1 && $result2 && $result3');
      return result1 && result2 && result3;
    } catch (e) {
      log('❌ Error clearing cache for key "$key": $e');
      return false;
    }
  }

  /// Clear all cache
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

  /// Check if cache exists for a specific key
  Future<bool> hasCache(String key) async {
    await init();
    final dataKey = '${key}_data';
    return _prefs!.containsKey(dataKey);
  }

  /// Check if cache is valid for a specific key
  Future<bool> isCacheValid(String key) async {
    return await _isCacheValid(key);
  }

  /// Get cache info for debugging
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

  /// Get all cached keys
  Future<List<String>> getAllCachedKeys() async {
    await init();
    final allKeys = _prefs!.getKeys();
    final cacheKeys = <String>{};

    // Extract unique cache keys (remove suffixes)
    for (final key in allKeys) {
      if (key.endsWith('_data')) {
        cacheKeys.add(key.substring(0, key.length - 5)); // Remove '_data'
      }
    }

    return cacheKeys.toList();
  }

  /// Force refresh cache for a specific key (clear it)
  Future<bool> forceRefresh(String key) async {
    final result = await clearCache(key);
    log('🔄 Force refresh for key "$key" - cache cleared: $result');
    return result;
  }

  /// Get cache size in bytes (approximate)
  Future<int> getCacheSize() async {
    await init();
    int totalSize = 0;

    final keys = _prefs!.getKeys();
    for (final key in keys) {
      final value = _prefs!.get(key);
      if (value is String) {
        totalSize += value.length * 2; // UTF-16 encoding
      } else if (value is int) {
        totalSize += 8; // 64-bit integer
      } else if (value is bool) {
        totalSize += 1;
      } else if (value is double) {
        totalSize += 8; // 64-bit double
      }
    }

    return totalSize;
  }

  /// Clean up expired cache entries
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

// =========================== CACHE KEYS CONSTANTS ===========================

/// Constants for cache keys to avoid typos and maintain consistency
class CacheKeys {
  static const String libraryStatistics = 'library_statistics';
  static const String booksWithCategories = 'books_with_categories';
  static const String userProfile = 'user_profile';
  static const String userStats = 'user_stats';
  static const String bookmarks = 'bookmarks';
  static const String bookmarkCollections = 'bookmark_collections';
  static const String localHadithResponse = 'localHadithRespose';
  static const String adabHadithResponse = 'adabHadithResponse';

  static const String remoteHadithResponse = 'remoteHadithResponse';

  static const String bookCategoryResponse = 'bookCategoryResponse';
  static const String collectionBookmarksResponse =
      'collectionBookmarksResponse';

  static const String chaptersResponse = 'chaptersResponse';
  static const String hadithDaily = 'hadithDaily';
  static const String library = 'library';
  static const String hadithCategories = 'hadith_categories';

  /// Paginated ahadith cache key generator
  static String paginatedAhadith(String bookSlug, int chapterId) =>
      'ahadith_${bookSlug}_$chapterId';

  /// Chapters cache key generator
  static String chapters(String bookSlug) => 'chapters_$bookSlug';

  /// Book data cache key generator
  static String bookData(String categoryId) => 'book_data_$categoryId';

  /// Navigation cache key generator
  static String navigation(
    String bookSlug,
    int chapterNumber,
    String hadithNumber,
  ) => 'nav_${bookSlug}_${chapterNumber}_$hadithNumber';

  /// Search cache key generator
  static String search(String query) => 'search_${query.hashCode}';

  /// Enhanced search cache key generator
  static String enhancedSearch(String query) =>
      'enhanced_search_${query.hashCode}';

  /// Search with filters cache key generator
  static String searchWithFilters(String query, String? bookSlug) =>
      'search_filtered_${query.hashCode}_${bookSlug ?? 'all'}';

  /// Ahadith by category cache key generator
  static String ahadithByCategory(String categoryId, int page, int perPage) =>
      'ahadith_by_category_${categoryId}_${page}_$perPage';
}

// =========================== TYPE-SAFE CACHE EXTENSIONS ===========================

/// Extension methods for commonly used data types
extension CacheExtensions on GenericCacheService {
  /// Save statistics with predefined settings
  Future<bool> saveStatistics(StatisticsResponse statistics) async {
    return await saveData<dynamic>(
      key: CacheKeys.libraryStatistics,
      data: statistics,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get statistics from cache
  Future<T?> getStatistics<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.libraryStatistics,
      fromJson: fromJson,
    );
  }

  /// Save books with predefined settings
  Future<bool> saveBooks(BooksResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.booksWithCategories,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getBooks<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.booksWithCategories,
      fromJson: fromJson,
    );
  }

  //get Three types of hadith

  Future<bool> saveLocalHadith(LocalHadithResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.localHadithResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getLocalHadith<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.localHadithResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveAdabHadith(LocalHadithResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.adabHadithResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getAdabHadith<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.adabHadithResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveRemoteHadith(HadithResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.remoteHadithResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getRemoteHadith<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.remoteHadithResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveBookCategory(CategoryResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.bookCategoryResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getBookCategory<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.bookCategoryResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveBookmarks(BookmarksResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.bookmarks,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getBookmarks<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(key: CacheKeys.bookmarks, fromJson: fromJson);
  }

  Future<bool> saveCollectionBookmarks(CollectionsResponse books) async {
    return await saveData<dynamic>(
      key: CacheKeys.collectionBookmarksResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getCollectinsBookmarks<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.collectionBookmarksResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveChapters(ChaptersModel books) async {
    return await saveData<dynamic>(
      key: CacheKeys.chaptersResponse,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getChapters<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(
      key: CacheKeys.chaptersResponse,
      fromJson: fromJson,
    );
  }

  Future<bool> saveHadithDaily(HadithData books) async {
    return await saveData<dynamic>(
      key: CacheKeys.hadithDaily,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getHadithDaily<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(key: CacheKeys.hadithDaily, fromJson: fromJson);
  }

  Future<bool> saveUser(UserResponseModel books) async {
    return await saveData<dynamic>(
      key: CacheKeys.userProfile,
      data: books,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Get books from cache
  Future<T?> getUser<T>({
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return await getData<T>(key: CacheKeys.userProfile, fromJson: fromJson);
  }
}
