import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class SuggestionService {
  final Dio _dio = Dio();

  SuggestionService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
        compact: true,
      ),
    );
  }

  Future<bool> sendSuggestion(String suggestion) async {
    const String url =
        'https://script.google.com/macros/s/AKfycbxnb0r11KKu_kfalssuLIShI3emP_iJuKWTDtGjKM1KO3RwshWrtLuV8HpFTzY_Gd_IPA/exec';

    try {
      final response = await _dio.post(
        url,
        data: {'suggestion': suggestion},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status < 400,
          responseType: ResponseType.json,
        ),
      );

      log('🔹 Status Code: ${response.statusCode}');
      log('🔹 Response Data: ${response.data}');
      log('🔹 Redirect URL: ${response.headers['location']}');

      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location']?.first;
        if (redirectUrl != null) {
          log('➡️ Redirecting to: $redirectUrl');
          final redirectedResponse = await _dio.get(redirectUrl);
          log('🔁 Redirected response: ${redirectedResponse.data}');
          return true;
        }
      }

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['result'] == 'success') {
          log('✅ Suggestion sent successfully');
          return true;
        } else if (response.data is String &&
            response.data.contains('success')) {
          log('✅ Suggestion sent (HTML response)');
          return true;
        }
      }

      log('❌ Failed to send suggestion: ${response.statusCode}');
      return false;
    } catch (e) {
      log('⚠️ Error sending suggestion: $e');
      if (e is DioException) {
        log ('Response: ${e.response?.data}');
      }
      return false;
    }
  }
}
