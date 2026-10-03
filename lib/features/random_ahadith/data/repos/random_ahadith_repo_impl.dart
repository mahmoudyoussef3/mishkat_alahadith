import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/custom_api_service.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/models/random_ahadith_model.dart';

class RandomAhadithRepo {
  final CustomApiService _customApiService;

  RandomAhadithRepo(this._customApiService);

  Future<Either<ApiErrorModel, RandomAhadithResponse>> getRandom() async {
    try {
      final reponse = await _customApiService.getRandomAhadith();
      return Right(reponse);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
