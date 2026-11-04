import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/pause_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/play_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/prepare_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/resume_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stop_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_playback_use_case.dart';

part 'azkar_audio_state.dart';

/// Plays the recitations on one screen, and silences them when it closes.
class AzkarAudioCubit extends Cubit<AzkarAudioState> {
  final PrepareAzkarAudioUseCase _prepare;
  final PlayAzkarAudioUseCase _play;
  final PauseAzkarAudioUseCase _pause;
  final ResumeAzkarAudioUseCase _resume;
  final StopAzkarAudioUseCase _stop;
  final WatchAzkarPlaybackUseCase _watch;

  StreamSubscription<AzkarPlaybackStatus>? _playback;

  /// Bumped by every request, so a download that finishes after the reader
  /// has moved on is never played.
  var _request = 0;

  /// Until the player has been told to play: on the way it passes through
  /// states that are not the reader's to see, such as loaded but not yet
  /// playing.
  var _starting = false;

  /// The latest status heard while [_starting], applied once the player has
  /// been told to play — so a recitation that never gets going, held back by
  /// a call or another app, shows as paused rather than loading for good.
  AzkarPlaybackStatus? _heldStatus;

  AzkarAudioCubit(
    this._prepare,
    this._play,
    this._pause,
    this._resume,
    this._stop,
    this._watch,
  ) : super(const AzkarAudioIdle());

  /// Plays [track], or pauses or resumes it when it is the one on the
  /// player.
  Future<void> toggle(AzkarAudioTrack track) async {
    final current = state;
    if (current is AzkarAudioActive && current.track == track) {
      switch (current.status) {
        case AzkarPlaybackStatus.playing:
          return pause();
        case AzkarPlaybackStatus.paused:
          return resume();
        case AzkarPlaybackStatus.loading:
          return;
        case AzkarPlaybackStatus.idle || AzkarPlaybackStatus.completed:
          break;
      }
    }
    return play(track);
  }

  Future<void> play(AzkarAudioTrack track) async {
    final request = ++_request;
    _starting = true;
    _heldStatus = null;
    _playback ??= _watch().listen(_onStatus, onError: _onPlayerError);
    emit(AzkarAudioActive(track: track, status: AzkarPlaybackStatus.loading));
    await _stop();

    final prepared = await _prepare(track.audioFile);
    if (isClosed || request != _request) return;
    final failure = switch (prepared) {
      ApiFailure(:final failure) => failure,
      ApiSuccess(data: final path) => switch (await _play(path)) {
        ApiFailure(:final failure) => failure,
        ApiSuccess() => null,
      },
    };
    if (isClosed || request != _request) return;
    if (failure != null) return _fail(track, failure.message);
    if (!_starting) return;
    _starting = false;
    final held = _heldStatus;
    _heldStatus = null;
    if (held != null) _onStatus(held);
  }

  Future<void> pause() async {
    final current = state;
    if (current is! AzkarAudioActive) return;
    emit(
      AzkarAudioActive(
        track: current.track,
        status: AzkarPlaybackStatus.paused,
      ),
    );
    if (await _pause() case ApiFailure(:final failure)) {
      _fail(current.track, failure.message);
    }
  }

  Future<void> resume() async {
    final current = state;
    if (current is! AzkarAudioActive) return;
    emit(
      AzkarAudioActive(
        track: current.track,
        status: AzkarPlaybackStatus.playing,
      ),
    );
    if (await _resume() case ApiFailure(:final failure)) {
      _fail(current.track, failure.message);
    }
  }

  Future<void> stop() async {
    _request++;
    _starting = false;
    emit(const AzkarAudioIdle());
    await _stop();
  }

  /// The failure has been shown; the player goes back to rest.
  void dismissFailure() {
    if (state is AzkarAudioFailure) emit(const AzkarAudioIdle());
  }

  void _onStatus(AzkarPlaybackStatus status) {
    final current = state;
    if (isClosed || current is! AzkarAudioActive) return;
    if (_starting && status != AzkarPlaybackStatus.playing) {
      _heldStatus = status;
      return;
    }
    _starting = false;
    _heldStatus = null;
    switch (status) {
      case AzkarPlaybackStatus.completed:
        emit(const AzkarAudioIdle());
      case AzkarPlaybackStatus.idle:
        // Only stop() empties the player, and it says so itself.
        return;
      case AzkarPlaybackStatus.loading ||
          AzkarPlaybackStatus.playing ||
          AzkarPlaybackStatus.paused:
        if (status != current.status) {
          emit(AzkarAudioActive(track: current.track, status: status));
        }
    }
  }

  void _onPlayerError(Object error) {
    final track = state.track;
    if (isClosed || track == null) return;
    _fail(track, error is Failure ? error.message : FailureMessages.audio);
  }

  void _fail(AzkarAudioTrack track, String message) {
    _request++;
    _starting = false;
    emit(AzkarAudioFailure(track: track, message: message));
  }

  @override
  Future<void> close() async {
    _request++;
    await _playback?.cancel();
    await _stop();
    return super.close();
  }
}
