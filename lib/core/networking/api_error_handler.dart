import 'dart:developer';

import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import 'api_error_model.dart';
import 'api_result.dart';

Future<ApiResult<T>> guardApiCall<T>(Future<T> Function() action) async {
  try {
    return ApiResult.success(await action());
  } catch (error, stackTrace) {
    log('Data call failed', error: error, stackTrace: stackTrace);
    return ApiResult.failure(ErrorHandler.toFailure(error));
  }
}

class ErrorHandler {
  static Failure toFailure(Object error) {
    if (error is UnauthorizedException) return const UnauthorizedFailure();
    if (error is NoConnectionException) return const NetworkFailure();
    if (error is! DioException) return const UnexpectedFailure();

    final response = error.response;
    if (response != null) {
      final body = _handleError(response.data, statusCode: response.statusCode);
      final messageAr = body.messageAr;
      final hasArabicMessage = messageAr != null && messageAr.isNotEmpty;
      if (response.statusCode == 401) {
        return UnauthorizedFailure(
          hasArabicMessage ? messageAr : FailureMessages.unauthorized,
        );
      }
      return ServerFailure(
        hasArabicMessage ? messageAr : FailureMessages.server,
        response.statusCode,
      );
    }
    return NetworkFailure(
      handle(error).message ?? FailureMessages.noConnection,
    );
  }

  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      if (response != null) {
        return _handleError(response, statusCode: response.statusCode);
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(
            message:
                "يبدو أن هناك بطء في شبكة الإنترنت، يرجى المحاولة مرة أخرى.",
          );
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(
            message:
                "عذراً، الخادم يستغرق وقتاً طويلاً للاستجابة. حاول مجدداً لاحقاً.",
          );
        case DioExceptionType.connectionError:
          return ApiErrorModel(
            message:
                "يبدو أنك غير متصل بالإنترنت. يرجى التحقق من اتصالك والمحاولة مجدداً.",
          );

        case DioExceptionType.badResponse:
          return _handleError(error.response?.data);
        case DioExceptionType.cancel:
          return ApiErrorModel(message: "تم إلغاء الطلب.");
        default:
          return ApiErrorModel(
            message: "عذراً، لم نتمكن من جلب البيانات الآن.",
          );
      }
    }

    return ApiErrorModel(message: "حدث خطأ غير متوقع");
  }

  static ApiErrorModel _handleError(dynamic data, {int? statusCode}) {
    if (data == null) {
      return ApiErrorModel(
        message: "عذراً، لم نتمكن من جلب البيانات الآن. نرجو المحاولة لاحقاً.",
      );
    }

    try {
      if (data is String) {
        return ApiErrorModel(message: data);
      }

      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        final messageAr = data['messageAr']?.toString();
        final success =
            data['success'] is bool ? data['success'] as bool : null;
        final status =
            data['status'] is int ? data['status'] as int : statusCode;

        return ApiErrorModel(
          message: message,
          messageAr: messageAr,
          success: success,
          status: status,
        );
      }

      return ApiErrorModel(message: data.toString());
    } catch (_) {
      return ApiErrorModel(message: "عذراً، حدث خطأ أثناء معالجة البيانات.");
    }
  }
}
