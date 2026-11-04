import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/azkar_audio.dart';
import '../../domain/repos/azkar_audio_repo.dart';
import '../datasources/azkar_audio_cache_datasource.dart';
import '../datasources/azkar_audio_player_datasource.dart';

class AzkarAudioRepoImpl implements AzkarAudioRepo {
  final AzkarAudioCacheDataSource _cache;
  final AzkarAudioPlayerDataSource _player;

  AzkarAudioRepoImpl(this._cache, this._player);

  /// Abandons any other download under way: one player plays one
  /// recitation, so only the newest request is worth the data.
  @override
  Future<ApiResult<String>> prepare(String audioFile) async {
    _cache.cancelDownloads(except: audioFile);
    try {
      return ApiResult.success(await _cache.resolve(audioFile));
    } on DioException catch (error, stackTrace) {
      log('Azkar audio download failed', error: error, stackTrace: stackTrace);
      // A reply means the file is missing upstream; no reply, the network.
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return ApiResult.failure(
          ServerFailure(FailureMessages.audioUnavailable, statusCode),
        );
      }
      return ApiResult.failure(ErrorHandler.toFailure(error));
    } catch (error, stackTrace) {
      log('Azkar audio unavailable', error: error, stackTrace: stackTrace);
      return const ApiResult.failure(
        UnexpectedFailure(FailureMessages.audioUnavailable),
      );
    }
  }

  @override
  Future<ApiResult<void>> play(String localPath) =>
      _guard(() => _player.playFile(localPath));

  @override
  Future<ApiResult<void>> pause() => _guard(_player.pause);

  @override
  Future<ApiResult<void>> resume() => _guard(_player.resume);

  /// Abandons any download under way too.
  @override
  Future<ApiResult<void>> stop() {
    _cache.cancelDownloads();
    return _guard(_player.stop);
  }

  /// Failures from the player, which just_audio reports apart from its
  /// states, arrive as errors carrying an [UnexpectedFailure].
  @override
  Stream<AzkarPlaybackStatus> watchStatus() {
    StreamSubscription<PlayerState>? states;
    StreamSubscription<PlayerException>? errors;
    late final StreamController<AzkarPlaybackStatus> controller;

    void fail(Object error, [StackTrace? stackTrace]) {
      log('Azkar player error', error: error, stackTrace: stackTrace);
      controller.addError(const UnexpectedFailure(FailureMessages.audio));
    }

    controller = StreamController(
      onListen: () {
        states = _player.playerStates.listen(
          (state) => controller.add(_statusOf(state)),
          onError: fail,
        );
        errors = _player.errors.listen(fail, onError: fail);
      },
      onCancel: () async {
        await states?.cancel();
        await errors?.cancel();
      },
    );
    return controller.stream;
  }

  static AzkarPlaybackStatus _statusOf(PlayerState state) => switch (state
      .processingState) {
    ProcessingState.idle => AzkarPlaybackStatus.idle,
    ProcessingState.loading ||
    ProcessingState.buffering => AzkarPlaybackStatus.loading,
    ProcessingState.ready =>
      state.playing ? AzkarPlaybackStatus.playing : AzkarPlaybackStatus.paused,
    ProcessingState.completed => AzkarPlaybackStatus.completed,
  };

  Future<ApiResult<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const ApiResult.success(null);
    } catch (error, stackTrace) {
      log('Azkar player failed', error: error, stackTrace: stackTrace);
      return const ApiResult.failure(UnexpectedFailure(FailureMessages.audio));
    }
  }
}
