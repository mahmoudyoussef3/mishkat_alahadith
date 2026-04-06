import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';

/// Cached response wrapper for paginated ahadith
class CachedAhadithData {
  final List<Hadith> ahadith;
  final int lastPage;
  final int totalCount;
  final DateTime cachedAt;

  CachedAhadithData({
    required this.ahadith,
    required this.lastPage,
    required this.totalCount,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'ahadith': ahadith.map((h) => h.toJson()).toList(),
    'lastPage': lastPage,
    'totalCount': totalCount,
    'cachedAt': cachedAt.millisecondsSinceEpoch,
  };

  factory CachedAhadithData.fromJson(Map<String, dynamic> json) {
    return CachedAhadithData(
      ahadith:
          (json['ahadith'] as List)
              .map((h) => Hadith.fromJson(h as Map<String, dynamic>))
              .toList(),
      lastPage: json['lastPage'] as int? ?? 1,
      totalCount: json['totalCount'] as int? ?? 0,
      cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
    );
  }
}

class AhadithsRepo {
  AhadithsRepo(this._apiService);
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  /// Get cached ahadith for a book/chapter
  Future<CachedAhadithData?> getCachedAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    final cacheKey = CacheKeys.paginatedAhadith(bookSlug, chapterId);
    return await _cacheService.getData<CachedAhadithData>(
      key: cacheKey,
      fromJson: CachedAhadithData.fromJson,
    );
  }

  /// Save ahadith to cache
  Future<void> cacheAhadith({
    required String bookSlug,
    required int chapterId,
    required List<Hadith> ahadith,
    required int lastPage,
    required int totalCount,
  }) async {
    final cacheKey = CacheKeys.paginatedAhadith(bookSlug, chapterId);
    final cachedData = CachedAhadithData(
      ahadith: ahadith,
      lastPage: lastPage,
      totalCount: totalCount,
      cachedAt: DateTime.now(),
    );
    await _cacheService.saveData<CachedAhadithData>(
      key: cacheKey,
      data: cachedData,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  /// Merge new ahadith with existing, removing duplicates by ID
  List<Hadith> mergeAhadith(List<Hadith> existing, List<Hadith> newItems) {
    final existingIds = existing.map((h) => h.id).toSet();
    final uniqueNew = newItems.where((h) => !existingIds.contains(h.id));
    return [...existing, ...uniqueNew];
  }

  Future<Either<ApiErrorModel, HadithResponse>> getAhadith({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
  }) async {
    try {
      final response = await _apiService.getChapterAhadiths(
        bookSlug,
        chapterId,
        page,
        paginate,
      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, LocalHadithResponse>> getLocalAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    try {
      final response = await _apiService.getLocalChapterAhadiths(
        bookSlug,
        chapterId,
      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, LocalHadithResponse>> getThreeAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    try {
      final response = await _apiService.getThreeBooksLocalChapterAhadiths(
        bookSlug,
        chapterId,
      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }
}
