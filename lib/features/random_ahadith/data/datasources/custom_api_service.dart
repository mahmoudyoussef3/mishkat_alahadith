import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/models/login_response_body.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/models/random_ahadith_model.dart';

import 'package:retrofit/retrofit.dart';

part 'custom_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.customBaseUrl)
abstract class CustomApiService {
  factory CustomApiService(Dio dio, {String baseUrl}) = _CustomApiService;

  @GET(ApiConstants.randomAhadith)
  Future<RandomAhadithResponse> getRandomAhadith();

}
