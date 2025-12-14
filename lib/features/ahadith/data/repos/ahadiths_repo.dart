import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';

class AhadithsRepo {
  AhadithsRepo(this._apiService);
  final ApiService _apiService;

  Future<Either<ApiErrorModel, HadithResponse>> getAhadith({
    required String bookSlug,
    required int chapterId,
      required int page,
  required int paginate,
  }) async {
    try {
      final response = await _apiService.getChapterAhadiths(
        bookSlug,
        chapterId,
        page,
  paginate,
        
      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, LocalHadithResponse>> getLocalAhadith({
    required String bookSlug,
    required int chapterId,

  }) async {
    try {
      final response = await _apiService.getLocalChapterAhadiths(
        bookSlug,
        chapterId,

      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, LocalHadithResponse>> getThreeAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    try {
      final response = await _apiService.getThreeBooksLocalChapterAhadiths(
        bookSlug,
        chapterId,
      );

      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }
}
