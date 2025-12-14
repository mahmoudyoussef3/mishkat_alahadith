import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/models/public_search_model.dart';

class PublicSearchRepo {
  final ApiService _apiService;
  PublicSearchRepo(this._apiService);

  Future<Either<ApiErrorModel, SearchResponse>> getPublicSearchRepo(
    String query,
  ) async {
    try {
      final response = await _apiService.getpublicSearch(query);

      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
