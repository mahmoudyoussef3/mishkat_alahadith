import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserResponseRepo {
  final ApiService apiService;

  UserResponseRepo(this.apiService);

  Future<Either<ApiErrorModel, UserResponseModel>> getUserProfile() async {
    try {
      final String token = await _getUserToken();
      final response = await apiService.getUserProfile(token);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, StatsModel>> getUserStats() async {
    try {
      final String token = await _getUserToken();
      final response = await apiService.getUserStats(token);
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