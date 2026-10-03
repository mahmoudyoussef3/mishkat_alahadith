import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

void main() {
  group('ApiResult.when', () {
    test('runs the success branch with the data', () {
      const ApiResult<int> result = ApiResult.success(42);

      final value = result.when(success: (data) => 'ok $data', failure: (_) => 'ko');

      expect(value, 'ok 42');
    });

    test('runs the failure branch with the failure', () {
      const ApiResult<int> result = ApiResult.failure(NetworkFailure());

      final value = result.when(
        success: (_) => 'ok',
        failure: (failure) => failure.message,
      );

      expect(value, FailureMessages.noConnection);
    });
  });
}
