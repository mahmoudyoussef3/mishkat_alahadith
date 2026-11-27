import 'dart:developer';

import '../errors/failures.dart';
import 'api_error_handler.dart';
import 'api_result.dart';
import 'caching_helper.dart';

/// Network-first reads that keep working without a connection.
extension StaleCacheFallback on GenericCacheService {
  /// Runs [fetch] and keeps its answer under [key]. When the server cannot
  /// be reached or cannot answer, the last answer kept under [key] is
  /// returned instead, however old, so the screen still has something to
  /// show offline.
  ///
  /// A refusal from the server (401, or any other 4xx) is passed on as it
  /// is: it is an answer, not an outage, and an old copy would hide it.
  Future<ApiResult<E>> fetchWithStaleFallback<M, E>({
    required String key,
    required Future<M> Function() fetch,
    required Map<String, dynamic> Function(M model) toJson,
    required M Function(Map<String, dynamic> json) fromJson,
    required E Function(M model) toEntity,
    int cacheExpirationHours = 24,
  }) async {
    try {
      final model = await fetch();
      // Mapped before it is kept, so an answer that cannot be read never
      // replaces one that can.
      final entity = toEntity(model);
      await saveData<M>(
        key: key,
        data: model,
        toJson: toJson,
        cacheExpirationHours: cacheExpirationHours,
      );
      return ApiResult.success(entity);
    } catch (error, stackTrace) {
      log('Fetching "$key" failed', error: error, stackTrace: stackTrace);
      final failure = ErrorHandler.toFailure(error);
      if (!_isOutage(failure)) return ApiResult.failure(failure);

      final stale = await getData<M>(
        key: key,
        fromJson: fromJson,
        allowStale: true,
      );
      if (stale == null) return ApiResult.failure(failure);
      try {
        final entity = toEntity(stale);
        log('📦 Served cached "$key" after: $failure');
        return ApiResult.success(entity);
      } catch (mapError, mapStack) {
        log('Cached "$key" unreadable', error: mapError, stackTrace: mapStack);
        return ApiResult.failure(failure);
      }
    }
  }

  /// 408 is the server giving up waiting, not a refusal; 429 stays a
  /// refusal, since it is how a quota says no.
  static bool _isOutage(Failure failure) => switch (failure) {
    UnauthorizedFailure() => false,
    ServerFailure(statusCode: 408) => true,
    ServerFailure(:final statusCode?)
        when statusCode >= 400 && statusCode < 500 =>
      false,
    _ => true,
  };
}
