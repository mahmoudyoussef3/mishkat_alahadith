import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../networking/api_constants.dart';

class HadeethEncDataSource {
  static final Dio _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.hadithCategoriesBaseApi,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    )
    ..interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );

  Future<NewDailyHadithModel> fetchHadith(String id) async {
    final response = await _dio.get(
      "hadeeths/one/",
      queryParameters: {"language": "ar", "id": id},
    );
    return NewDailyHadithModel.fromJson(response.data);
  }
}
