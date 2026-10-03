import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/remaining_questions/data/models/remaining_questions_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemainingQuestionsRepo {
  final ApiService _apiService;
  RemainingQuestionsRepo(this._apiService);
  Future<Either<ApiErrorModel, RmainingQuestionsResponse>>
  getRemainingQuestions() async {
    try {
      final String token = await _getUserToken();
      final response = await _apiService.getReaminingQuestions(token);

      return Right(response);
    } catch (e) {
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
