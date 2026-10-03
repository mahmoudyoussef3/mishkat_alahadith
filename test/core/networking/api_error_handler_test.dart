import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

DioException _dioError({
  DioExceptionType type = DioExceptionType.badResponse,
  Object? body,
  int? statusCode,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response:
        statusCode == null
            ? null
            : Response(
              requestOptions: options,
              statusCode: statusCode,
              data: body,
            ),
  );
}

void main() {
  group('ErrorHandler.toFailure', () {
    test('maps a server response to ServerFailure with its Arabic message', () {
      final failure = ErrorHandler.toFailure(
        _dioError(
          statusCode: 400,
          body: {'message': 'Invalid', 'messageAr': 'بيانات غير صحيحة'},
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'بيانات غير صحيحة');
      expect((failure as ServerFailure).statusCode, 400);
    });

    test('hides an English-only server message behind the Arabic default', () {
      final failure = ErrorHandler.toFailure(
        _dioError(statusCode: 500, body: {'message': 'Internal error'}),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.message, FailureMessages.server);
    });

    test(
      'maps a 401 response to UnauthorizedFailure with the server message',
      () {
        final failure = ErrorHandler.toFailure(
          _dioError(statusCode: 401, body: {'messageAr': 'انتهت الجلسة'}),
        );

        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, 'انتهت الجلسة');
      },
    );

    test(
      'maps a 401 without an Arabic message to the default sign-in prompt',
      () {
        final failure = ErrorHandler.toFailure(
          _dioError(statusCode: 401, body: {'message': 'jwt expired'}),
        );

        expect(failure, isA<UnauthorizedFailure>());
        expect(failure.message, FailureMessages.unauthorized);
      },
    );

    test(
      'maps a connection timeout to NetworkFailure with an Arabic message',
      () {
        final failure = ErrorHandler.toFailure(
          _dioError(type: DioExceptionType.connectionTimeout),
        );

        expect(failure, isA<NetworkFailure>());
        expect(failure.message, contains('الإنترنت'));
      },
    );

    test('maps a missing session token to UnauthorizedFailure', () {
      expect(
        ErrorHandler.toFailure(const UnauthorizedException()),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps a pre-flight offline check to NetworkFailure', () {
      final failure = ErrorHandler.toFailure(const NoConnectionException());

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, FailureMessages.noConnection);
    });

    test('maps any other error to UnexpectedFailure', () {
      expect(
        ErrorHandler.toFailure(const FormatException('bad json')),
        isA<UnexpectedFailure>(),
      );
    });
  });

  group('guardApiCall', () {
    test('wraps the returned value in a success', () async {
      final result = await guardApiCall(() async => 42);

      expect((result as ApiSuccess<int>).data, 42);
    });

    test('maps a thrown error to a typed failure', () async {
      final result = await guardApiCall<int>(
        () async => throw const NoConnectionException(),
      );

      expect((result as ApiFailure<int>).failure, isA<NetworkFailure>());
    });
  });
}
