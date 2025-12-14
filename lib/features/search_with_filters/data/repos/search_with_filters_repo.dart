import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';

class SearchWithFiltersRepo {
  final ApiService _apiService;
  SearchWithFiltersRepo(this._apiService);

  Future<Either<ApiErrorModel, SearchWithFiltersModel>> searchWithFilters({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapter,
    required String category
  }) async {
    try {
      final response = await _apiService.searchWithFilters(
        searchQuery,
        bookSlug,
        narrator,
        grade,
        chapter,
        category
      );

      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}
