import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/serag_hadith_context.dart';
import '../../domain/repos/serag_repo.dart';
import '../mappers/serag_mapper.dart';
import '../models/serag_request_model.dart';

class SeragRepoImpl implements SeragRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  SeragRepoImpl(this._apiService, this._tokenStorage);

  @override
  Future<ApiResult<String>> ask({
    required SeragHadithContext hadith,
    required String question,
  }) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.serag(
        SeragRequestModel(
          hadith: hadith.toModel(),
          messages: [Message(role: 'user', content: question)],
        ),
        token,
      );
      return ApiResult.success(response.response);
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
