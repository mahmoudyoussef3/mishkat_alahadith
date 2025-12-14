import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';

class EnhancedSearchRepo {
  final ApiService _apiService;
  EnhancedSearchRepo(this._apiService);

  Future<Either<ApiErrorModel, EnhancedSearch>> fetchEnhancedSearchResults(
    String searchTerm,
  ) async {
    try {
      final response = await _apiService.getEnhancedSearch({"searchTerm": searchTerm});
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
