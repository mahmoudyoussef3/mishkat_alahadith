import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/helpers/change_only_writer.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/last_azkar_audio_use_cases.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/pause_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/play_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/prepare_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/resume_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stand_by_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stop_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_audio_commands_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_audio_taken_over_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_playback_use_case.dart';

part 'azkar_audio_state.dart';

/// Plays the recitations of the azkar for the whole app: one plays on with
/// its chapter closed, the app in the background or swiped away, with its
/// controls outside the app and on the mini player over every screen. A
/// recitation of the Quran started meanwhile replaces it. The one the app
/// was closed on is offered again, held, the next time it opens.
class AzkarAudioCubit extends Cubit<AzkarAudioState> {
  final PrepareAzkarAudioUseCase _prepare;
  final PlayAzkarAudioUseCase _play;
  final PauseAzkarAudioUseCase _pause;
  final ResumeAzkarAudioUseCase _resume;
  final StopAzkarAudioUseCase _stop;
  final WatchAzkarPlaybackUseCase _watch;
  final StandByAzkarAudioUseCase _standBy;
  final WatchAzkarAudioCommandsUseCase _watchCommands;
  final GetLastAzkarAudioUseCase _getLast;

  /// The recitation on the player, kept for after the app is closed — once,
  /// not again as its status changes.
  final ChangeOnlyWriter<AzkarAudioTrack> _last;

  StreamSubscription<AzkarPlaybackStatus>? _playback;
  StreamSubscription<MediaCommand>? _commands;
  late final StreamSubscription<void> _takeovers;

  /// Bumped by every request, so a download that finishes after the reader
  /// has moved on is never played.
  var _request = 0;

  /// Until the player has been told to play: on the way it passes through
  /// states that are not the reader's to see, such as loaded but not yet
  /// playing — and, the player being the app's, may still report what it
  /// played before it was taken.
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
    this._standBy,
    this._watchCommands,
    WatchAzkarAudioTakenOverUseCase watchTakenOver,
    this._getLast,
    SaveLastAzkarAudioUseCase saveLast,
  ) : _last = ChangeOnlyWriter(saveLast.call),
      super(const AzkarAudioIdle()) {
    _takeovers = watchTakenOver().listen((_) => _onTakenOver());
  }

  /// Offers again, held, the recitation the app was last closed on —
  /// unless something has been asked for since.
  Future<void> restore() async {
    if (isClosed || state is! AzkarAudioIdle) return;
    final request = _request;
    final kept = await _getLast();
    if (isClosed || request != _request || state is! AzkarAudioIdle) return;
    if (kept case ApiSuccess(data: final track?)) {
      _last.read(track);
      emit(AzkarAudioSuspended(track: track));
    }
  }

  /// Plays [track], or pauses or resumes it when it is the one on the
  /// player; one offered again after the app was closed plays from the
  /// start.
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
    _commands ??= _watchCommands().listen(_onCommand);
    emit(AzkarAudioActive(track: track, status: AzkarPlaybackStatus.loading));
    // Takes the player at once, silencing whatever played — the Quran too —
    // while the recitation downloads.
    await _standBy();

    final prepared = await _prepare(track.audioFile);
    if (isClosed || request != _request) return;
    final failure = switch (prepared) {
      ApiFailure(:final failure) => failure,
      ApiSuccess(data: final path) => switch (await _play(path, track)) {
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
    if (_starting) {
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

  /// A control used outside the app — on the notification, the lock screen,
  /// headphones, a watch or a car — does what its button in the app does.
  void _onCommand(MediaCommand command) {
    if (isClosed) return;
    final current = state;
    switch (command) {
      case MediaCommand.play:
        switch (current) {
          case AzkarAudioActive(status: AzkarPlaybackStatus.paused):
            unawaited(resume());
          case AzkarAudioFailure(:final track) ||
              AzkarAudioSuspended(:final track):
            unawaited(play(track));
          case AzkarAudioActive() || AzkarAudioIdle():
            break;
        }
      case MediaCommand.pause:
        if (current is AzkarAudioActive) unawaited(pause());
      case MediaCommand.stop:
        unawaited(stop());
      // One recitation at a time: nothing to skip to.
      case MediaCommand.next || MediaCommand.previous:
        break;
    }
  }

  /// A recitation of the Quran took the player: whatever was recited, or
  /// offered to pick up again, is gone. The player is not this cubit's to
  /// stop any more.
  void _onTakenOver() {
    if (isClosed || state is AzkarAudioIdle) return;
    _request++;
    _starting = false;
    _heldStatus = null;
    emit(const AzkarAudioIdle());
  }

  void _onPlayerError(Object error) {
    final track = state.track;
    // While starting, the call to play reports the failure itself; one
    // heard meanwhile may be from what the player played before.
    if (isClosed || _starting || track == null) return;
    _fail(track, error is Failure ? error.message : FailureMessages.audio);
  }

  void _fail(AzkarAudioTrack track, String message) {
    _request++;
    _starting = false;
    emit(AzkarAudioFailure(track: track, message: message));
    // Takes down the controls kept up, loading, while it downloaded.
    unawaited(_stop());
  }

  /// Keeps the recitation on the player for after the app is closed, and
  /// forgets it once it is ended: stopped, finished, failed and dismissed,
  /// or replaced by the Quran.
  @override
  void onChange(Change<AzkarAudioState> change) {
    super.onChange(change);
    switch (change.nextState) {
      case AzkarAudioActive(:final track):
        _last.write(track);
      case AzkarAudioIdle() when change.currentState is! AzkarAudioIdle:
        _last.write(null);
      case AzkarAudioIdle() || AzkarAudioFailure() || AzkarAudioSuspended():
        break;
    }
  }

  @override
  Future<void> close() async {
    _request++;
    await _playback?.cancel();
    await _commands?.cancel();
    await _takeovers.cancel();
    await _stop();
    return super.close();
  }
}
