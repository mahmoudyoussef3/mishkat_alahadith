import 'package:dio/dio.dart';
import 'api_error_model.dart';

class ErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      if (response != null) {
        return _handleError(response, statusCode: response.statusCode);
      }

      // حالات بدون رد من السيرفر
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(message: "انتهت مهلة الاتصال");
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(message: "انتهت مهلة استقبال البيانات");
        case DioExceptionType.connectionError:
          return ApiErrorModel(message: "فشل الاتصال بالخادم");
        case DioExceptionType.badResponse:
          return _handleError(error.response?.data);
        case DioExceptionType.cancel:
          return ApiErrorModel(message: "تم إلغاء الطلب");
        default:
          return ApiErrorModel(message: "حدث خطأ غير متوقع");
      }
    }

    return ApiErrorModel(message: "حدث خطأ غير متوقع");
  }

static ApiErrorModel _handleError(dynamic data, {int? statusCode}) {
  if (data == null) {
    return ApiErrorModel(message: "حدث خطأ، حاول مرة أخرى.");
  }

  try {
    if (data is String) {
      return ApiErrorModel(message: data);
    }

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      final messageAr = data['messageAr']?.toString();
      final success = data['success'] is bool ? data['success'] as bool : null;
      final status = data['status'] is int ? data['status'] as int : statusCode;

      return ApiErrorModel(
        message: message,
        messageAr: messageAr,
        success: success,
        status: status,
      );
    }

    return ApiErrorModel(message: data.toString());
  } catch (_) {
    return ApiErrorModel(message: "حدث خطأ أثناء معالجة الرد.");
  }
}
}
