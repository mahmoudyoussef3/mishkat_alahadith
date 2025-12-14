import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/home/data/models/library_statistics_model.dart';

class GetLibraryStatisticsRepo {
  final ApiService _apiService;

  GetLibraryStatisticsRepo(this._apiService);

  Future<Either<ApiErrorModel, StatisticsResponse>>
  getLibraryStatistics() async {
    try {
      /*
        final cacheKey = CacheKeys.libraryStatistics;

      final cachedData = await GenericCacheService.instance
          .getData<StatisticsResponse>(
            key: cacheKey,
            fromJson: (json) => StatisticsResponse.fromJson(json),
          );

      if (cachedData != null) {
        return Right(cachedData);
      }
      */
      final response = await _apiService.getLibraryStatisctics();
/*
       await GenericCacheService.instance.saveData<StatisticsResponse>(
        key: cacheKey,
        data: response,
        toJson: (data) => data.toJson(),
        cacheExpirationHours: 100,
      );
      */
      return Right(response);

    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}