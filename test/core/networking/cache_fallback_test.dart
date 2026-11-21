import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'cache_fallback_test';

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.connectionError,
);

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: code),
  type: DioExceptionType.badResponse,
);

void main() {
  final cache = GenericCacheService.instance;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => cache.clearCache(_key));

  Future<ApiResult<String>> fetch(Future<String> Function() request) =>
      cache.fetchWithStaleFallback<String, String>(
        key: _key,
        fetch: request,
        toJson: (value) => {'value': value},
        fromJson: (json) => json['value'] as String,
        toEntity: (value) => value.toUpperCase(),
      );

  Future<void> keep(String value) => fetch(() async => value);

  test('returns the fresh answer and keeps it', () async {
    final result = await fetch(() async => 'fresh');

    expect((result as ApiSuccess<String>).data, 'FRESH');
    expect(
      await cache.getData<String>(key: _key, fromJson: (j) => j['value'] as String),
      'fresh',
    );
  });

  test('serves the kept answer when the connection fails', () async {
    await keep('kept');

    final result = await fetch(() => throw _offline());

    expect((result as ApiSuccess<String>).data, 'KEPT');
  });

  test('serves the kept answer when the device reports no connection', () async {
    await keep('kept');

    final result = await fetch(() => throw const NoConnectionException());

    expect((result as ApiSuccess<String>).data, 'KEPT');
  });

  test('serves the kept answer when the server fails with a 5xx', () async {
    await keep('kept');

    final result = await fetch(() => throw _status(503));

    expect((result as ApiSuccess<String>).data, 'KEPT');
  });

  test('serves an answer kept long past its expiry', () async {
    await cache.saveData<String>(
      key: _key,
      data: 'old',
      toJson: (value) => {'value': value},
      cacheExpirationHours: 0,
    );

    final result = await fetch(() => throw _offline());

    expect((result as ApiSuccess<String>).data, 'OLD');
  });

  test('fails when the connection fails and nothing was kept', () async {
    final result = await fetch(() => throw _offline());

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
  });

  test('serves the kept answer when the server times out with a 408', () async {
    await keep('kept');

    final result = await fetch(() => throw _status(408));

    expect((result as ApiSuccess<String>).data, 'KEPT');
  });

  test('passes on a 4xx refusal instead of the kept answer', () async {
    await keep('kept');

    final result = await fetch(() => throw _status(403));

    expect((result as ApiFailure).failure, isA<ServerFailure>());
  });

  test('passes on a missing session instead of the kept answer', () async {
    await keep('kept');

    final result = await fetch(() => throw const UnauthorizedException());

    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
  });

  test('does not keep an answer that cannot be mapped', () async {
    await keep('kept');

    final result = await cache.fetchWithStaleFallback<String, String>(
      key: _key,
      fetch: () async => 'broken',
      toJson: (value) => {'value': value},
      fromJson: (json) => json['value'] as String,
      toEntity: (value) => value == 'broken' ? throw const FormatException() : value,
    );

    expect((result as ApiSuccess<String>).data, 'kept');
  });

  test('getData skips expired data unless stale data is allowed', () async {
    await cache.saveData<String>(
      key: _key,
      data: 'old',
      toJson: (value) => {'value': value},
      cacheExpirationHours: 0,
    );

    String read(Map<String, dynamic> json) => json['value'] as String;
    expect(await cache.getData<String>(key: _key, fromJson: read), isNull);
    expect(
      await cache.getData<String>(key: _key, fromJson: read, allowStale: true),
      'old',
    );
  });
}
