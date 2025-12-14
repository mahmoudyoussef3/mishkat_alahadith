import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';

class GetBookDataRepo {
  final ApiService _apiService;

  GetBookDataRepo(this._apiService);

  Future<Either<ApiErrorModel, CategoryResponse>> getBookData(String id) async {
    try {
  //    final cacheKey = '${CacheKeys.bookCategoryResponse}_$id';

   /*   final cachedData = await GenericCacheService.instance
          .getData<CategoryResponse>(
            key: cacheKey,
            fromJson: (json) => CategoryResponse.fromJson(json),
          );
          */

    //  if (cachedData != null) {
    //    log('📂 Loaded Ahadith from cache for $id ');
    //    return Right(cachedData);
    //  }

      final response = await _apiService.getBookData(id);
   /*   await GenericCacheService.instance.saveData<CategoryResponse>(
        key: cacheKey,
        data: response,
        toJson: (data) => data.toJson(),
        cacheExpirationHours: 100,
      );
      */

      log('🌍 Loaded Ahadith from API and cached it for $id ');
      return Right(response);
    } catch (error) {
      log(error.toString());

      return Left(ErrorHandler.handle(error));
    }
  }
}
