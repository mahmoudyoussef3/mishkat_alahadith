import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileRepo {
  final ApiService apiService;
  EditProfileRepo(this.apiService);

  Future<Either<ApiErrorModel, UserResponseModel>> updateProfile({
    required String username,
    File? imageFile,
    
  }) async {
    try {
      final  String token = await _getUserToken();

      final response = await apiService.updateUserProfile(
    token,
    username,
    imageFile, 
  );
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