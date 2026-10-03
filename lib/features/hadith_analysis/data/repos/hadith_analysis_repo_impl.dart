import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/hadith_analysis_result.dart';
import '../../domain/repos/hadith_analysis_repo.dart';
import '../mappers/hadith_analysis_mapper.dart';
import '../models/hadith_analysis_request.dart';

class HadithAnalysisRepoImpl implements HadithAnalysisRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  HadithAnalysisRepoImpl(this._apiService, this._tokenStorage);

  @override
  Future<ApiResult<HadithAnalysisResult>> analyzeHadith({
    required String hadith,
    required String attribution,
    required String grade,
    required String reference,
  }) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.hadithAnalysis(
        HadithAnalysisRequest(
          hadeeth: hadith,
          attribution: attribution,
          grade: grade,
          reference: reference,
        ),
        token,
      );
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
