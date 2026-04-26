import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/home/data/models/library_statistics_model.dart';

class GetLibraryStatisticsRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  GetLibraryStatisticsRepo(this._apiService);

  /// Get cached statistics
  Future<StatisticsResponse?> getCachedStatistics() async {
    return await _cacheService.getData<StatisticsResponse>(
      key: CacheKeys.libraryStatistics,
      fromJson: StatisticsResponse.fromJson,
    );
  }

  /// Save statistics to cache
  Future<void> cacheStatistics(StatisticsResponse data) async {
    await _cacheService.saveData<StatisticsResponse>(
      key: CacheKeys.libraryStatistics,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  Future<Either<ApiErrorModel, StatisticsResponse>>
  getLibraryStatistics() async {
    try {
      final response = await _apiService.getLibraryStatisctics();
      // Cache the response
      await cacheStatistics(response);
      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}
