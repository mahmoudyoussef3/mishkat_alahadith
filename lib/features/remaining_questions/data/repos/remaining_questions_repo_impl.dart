import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/remaining_questions.dart';
import '../../domain/repos/remaining_questions_repo.dart';
import '../mappers/remaining_questions_mapper.dart';

class RemainingQuestionsRepoImpl implements RemainingQuestionsRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  RemainingQuestionsRepoImpl(this._apiService, this._tokenStorage);

  @override
  Future<ApiResult<RemainingQuestions>> getRemainingQuestions() async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.getReaminingQuestions(token);
      return ApiResult.success(response.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
