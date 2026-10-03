import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_request_model.dart';
import 'package:mishkat_almasabih/features/serag/data/models/serag_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeragRepo {
  final ApiService _apiService;
  SeragRepo(this._apiService);
  Future<Either<ApiErrorModel, SeragResponseModel>> serag(
    SeragRequestModel seragRequestModel,
  ) async {
    try {
      final String token = await _getUserToken();

      final response = await _apiService.serag(seragRequestModel, token);

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<String> _getUserToken() async {
    final sharedPref = await SharedPreferences.getInstance();
    final token = sharedPref.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("No token found, user not logged in");
    }
    return token;
  }
}
