import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/home/data/models/book_model.dart';

class GetAllBooksWithCategoriesRepo {
  final ApiService _apiService;

  GetAllBooksWithCategoriesRepo(this._apiService);


  Future<Either<ApiErrorModel, BooksResponse>>
  getAllBooksWithCategoriesRepo() async {
    try {


      
         final cacheKey = CacheKeys.booksWithCategories;

      final cachedData = await GenericCacheService.instance
          .getData<BooksResponse>(
            key: cacheKey,
            fromJson: (json) => BooksResponse.fromJson(json),
          );

      if (cachedData != null) {
        return Right(cachedData);
      }
            final response = await _apiService.getAllBooksWithCategories();
      
      await GenericCacheService.instance.saveData<BooksResponse>(
        key: cacheKey,
        data: response,
        toJson: (data) => data.toJson(),
        cacheExpirationHours: 100,
      );
      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}