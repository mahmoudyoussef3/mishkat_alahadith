import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio/dio.dart';

class HadithByCategoryDetailsRepo {

 static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://hadeethenc.com/api/v1/",
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  )..interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );

  static Dio get dio => _dio;


  Future<NewDailyHadithModel?> fetchHadith(String id) async {


    
    try {
      final response =
          await _dio.get("hadeeths/one/", queryParameters: {
        "language": "ar",
        "id": id,
      });

      final hadithModel = NewDailyHadithModel.fromJson(response.data);


      return hadithModel;
    } catch (e) {
      debugPrint("❌ Error fetching hadith: $e");
      return null;
    }
  }
}
