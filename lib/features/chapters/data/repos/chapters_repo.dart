import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';

class BookChaptersRepo {
  final ApiService _apiService;
  BookChaptersRepo(this._apiService);

  Future<Either<ApiErrorModel, ChaptersModel>> getBookChapters(
    String bookSlug,

  ) async {
    try {
      final response = await _apiService.getBookChapters(
        bookSlug,
      );

      return Right(response);
    } catch (error) {
      log(error.toString());
      return Left(ErrorHandler.handle(error));
    }
  }
}
