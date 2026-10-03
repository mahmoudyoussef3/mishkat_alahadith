import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';

class SearchHistoryRepo {
  final ApiService api;

  SearchHistoryRepo(this.api);

  Future<Either<dynamic, List<SearchHistoryItem>>> getSearchHistory({
    required String token,
   
  }) async {
    try {
      final response = await api.getSearchHistory(
        token,
    
      );
      return Right(response.data);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, AddSearchData>> addSearch({
    required String token,
    required AddSearchRequest body,
  }) async {
    try {
      final response = await api.addSearch(token, body);
      return Right(response.data);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, void>> deleteSearch({
    required String token,
    required int searchId,
  }) async {
    try {
      await api.deleteSearch(token, searchId);
      return const Right(null);
    } catch (e) {
      return Left(e);
    }
  }

  Future<Either<dynamic, void>> deleteAllSearch({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      await api.deleteAllSearch(token, body);
      return const Right(null);
    } catch (e) {
      return Left(e);
    }
  }

}
