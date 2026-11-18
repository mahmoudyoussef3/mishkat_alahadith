import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/helpers/change_only_writer.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/load_recitation_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/recitation_player_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/recitation_resume_use_cases.dart';

part 'quran_recitation_state.dart';

/// How a settings change reaches a recitation that is playing.
enum _Apply {
  /// Only the next recitation uses it.
  later,

  /// Applied to the player as it plays.
  speed,

  /// The same playlist, queued again from the current ayah.
  requeue,

  /// The playlist fetched again, from the current ayah.
  reload,
}

/// Recites the mushaf for the whole app: it plays on with the mushaf closed,
/// the app in the background or swiped away, with its controls outside the
/// app and on the mini player over every screen. A recitation of the azkar
/// started meanwhile replaces it. Where it was is kept, so a recitation the
/// app was closed on is offered again, held, the next time it opens.
class QuranRecitationCubit extends Cubit<QuranRecitationState> {
  final GetRecitationSettingsUseCase _getSettings;
  final SaveRecitationSettingsUseCase _saveSettings;
  final LoadRecitationUseCase _load;
  final PlayRecitationUseCase _play;
  final PauseRecitationUseCase _pause;
  final ResumeRecitationUseCase _resume;
  final StopRecitationUseCase _stop;
  final SkipToRecitationTrackUseCase _skipTo;
  final SetRecitationSpeedUseCase _setSpeed;
  final WatchRecitationUseCase _watch;
  final StandByRecitationUseCase _standBy;
  final WatchRecitationCommandsUseCase _watchCommands;
  final GetRecitationResumePointUseCase _getResumePoint;

  /// Where the recitation is, kept as it moves on — once per ayah, not
  /// again as the player's status changes.
  final ChangeOnlyWriter<RecitationResumePoint> _resumePoint;

  StreamSubscription<RecitationPlayback>? _playback;
  StreamSubscription<RecitationCommand>? _commands;
  late final StreamSubscription<void> _takeovers;
  Future<void>? _settingsLoad;

  /// Bumped by every request, so a playlist that arrives after the reader
  /// has moved on is never played.
  var _request = 0;

  /// Until the player has been told to play: on the way it passes through
  /// states that are not the reader's to see, and may still report the
  /// queue it is leaving.
  var _starting = false;

  /// The latest playback heard while [_starting], applied once the player
  /// has been told to play.
  RecitationPlayback? _held;

  /// The part already fetched ahead of time, so it is not fetched twice.
  RecitationScope? _prefetched;

  /// The request a pause from outside the app reached while it was being
  /// fetched: it starts paused, rather than the pause being lost.
  int? _pausedWhilePreparing;

  QuranRecitationCubit(
    this._getSettings,
    this._saveSettings,
    this._load,
    this._play,
    this._pause,
    this._resume,
    this._stop,
    this._skipTo,
    this._setSpeed,
    this._watch,
    this._standBy,
    this._watchCommands,
    WatchRecitationTakenOverUseCase watchTakenOver,
    this._getResumePoint,
    SaveRecitationResumePointUseCase saveResumePoint,
  ) : _resumePoint = ChangeOnlyWriter(saveResumePoint.call),
      super(const RecitationIdle(RecitationSettings.defaults)) {
    _takeovers = watchTakenOver().listen((_) => _onTakenOver());
  }

  /// Reads the saved settings, then starts [autoplay] if given.
  Future<void> init({RecitationRequest? autoplay}) async {
    await _ensureSettings();
    if (autoplay != null && !isClosed) await start(autoplay);
  }

  /// Offers again, held, the recitation the app was last closed on —
  /// unless something has been asked for since.
  Future<void> restore() async {
    await _ensureSettings();
    if (isClosed || state is! RecitationIdle) return;
    final request_ = _request;
    final kept = await _getResumePoint();
    if (isClosed || request_ != _request || state is! RecitationIdle) return;
    if (kept case ApiSuccess(data: final point?)) {
      _resumePoint.read(point);
      emit(RecitationSuspended(state.settings, point: point));
    }
  }

  // ── playback ────────────────────────────────────────────────────────────

  /// Plays what [request] asks for, replacing whatever was playing — or
  /// only readies it, held, when [paused].
  Future<void> start(RecitationRequest request, {bool paused = false}) async {
    await _ensureSettings();
    if (isClosed) return;
    final request_ = ++_request;
    _starting = true;
    _held = null;
    _playback ??= _watch().listen(_onPlayback, onError: _onPlayerError);
    _commands ??= _watchCommands().listen(_onCommand);
    emit(RecitationPreparing(state.settings, request: request));
    await _standBy();
    if (isClosed || request_ != _request) return;

    final loaded = await _load(request, state.settings);
    if (isClosed || request_ != _request) return;
    switch (loaded) {
      case ApiFailure(:final failure):
        _fail(failure.message, request);
      case ApiSuccess(data: (:final playlist, :final startIndex)):
        await _begin(
          playlist,
          startIndex,
          request_,
          paused: paused || _pausedWhilePreparing == request_,
        );
    }
  }

  /// Plays the ayah: from where it is in the playlist on the player, or
  /// else from it to the end of its surah.
  Future<void> playAyah(int ayahId) async {
    final current = state;
    if (current is RecitationActive) {
      final index = current.playlist.indexOfAyah(ayahId);
      if (index >= 0) {
        await _skip(current, index);
        if (state case RecitationActive(status: RecitationStatus.paused)) {
          await resume();
        }
        return;
      }
    }
    await start(RecitationFromAyah(ayahId));
  }

  /// Pauses or resumes, tries again after a failure, or picks up the
  /// recitation the app was closed on.
  Future<void> togglePlayPause() async {
    switch (state) {
      case RecitationActive(status: RecitationStatus.playing):
        await pause();
      case RecitationActive(status: RecitationStatus.paused):
        await resume();
      case RecitationFailure(:final request):
        await start(request);
      case RecitationSuspended(:final point):
        await start(point.request);
      case RecitationActive() || RecitationIdle() || RecitationPreparing():
        return;
    }
  }

  Future<void> pause() async {
    final current = state;
    if (current is! RecitationActive) return;
    emit(current.copyWith(status: RecitationStatus.paused));
    if (await _pause() case ApiFailure(:final failure)) {
      _fail(failure.message, _resumeRequest(current));
    }
  }

  Future<void> resume() async {
    final current = state;
    if (current is! RecitationActive) return;
    emit(current.copyWith(status: RecitationStatus.playing));
    if (await _resume() case ApiFailure(:final failure)) {
      _fail(failure.message, _resumeRequest(current));
    }
  }

  /// The next ayah, or the start of the next part after the last ayah.
  Future<void> next() async {
    final current = state;
    if (current is! RecitationActive) return;
    final index = current.trackIndex + 1;
    if (index < current.playlist.tracks.length) return _skip(current, index);
    final following = current.playlist.scope.next;
    if (following != null) await start(RecitationOfScope(following));
  }

  /// The ayah before, or the start of the first one.
  Future<void> previous() async {
    final current = state;
    if (current is! RecitationActive) return;
    await _skip(current, current.hasPrevious ? current.trackIndex - 1 : 0);
  }

  Future<void> stop() async {
    _request++;
    _starting = false;
    emit(RecitationIdle(state.settings));
    await _stop();
  }

  // ── settings ────────────────────────────────────────────────────────────

  Future<bool> setReciter(QuranEdition reciter) => _changeSettings(
    (s) => s.copyWith(reciterId: reciter.identifier, reciterName: reciter.name),
    _Apply.reload,
  );

  Future<bool> setRepeat(AyahRepeat repeat) =>
      _changeSettings((s) => s.copyWith(repeat: repeat), _Apply.requeue);

  Future<bool> setSpeed(RecitationSpeed speed) =>
      _changeSettings((s) => s.copyWith(speed: speed), _Apply.speed);

  Future<bool> setQuality(RecitationQuality quality) =>
      _changeSettings((s) => s.copyWith(quality: quality), _Apply.reload);

  Future<bool> setContinuous(bool continuous) =>
      _changeSettings((s) => s.copyWith(continuous: continuous), _Apply.later);

  /// Applies the change at once and persists it; `false` if it could not be
  /// saved for next time.
  Future<bool> _changeSettings(
    RecitationSettings Function(RecitationSettings) change,
    _Apply apply,
  ) async {
    await _ensureSettings();
    if (isClosed) return false;
    final current = state;
    final updated = change(current.settings);
    if (updated == current.settings) return true;
    emit(current.withSettings(updated));
    _prefetched = null;

    switch (current) {
      case RecitationActive():
        // A paused recitation stays paused through the change.
        final paused = current.status == RecitationStatus.paused;
        switch (apply) {
          case _Apply.later:
            break;
          case _Apply.speed:
            if (await _setSpeed(updated.speed) case ApiFailure(
              :final failure,
            )) {
              _fail(failure.message, _resumeRequest(current));
            }
          case _Apply.requeue:
            final request_ = ++_request;
            _starting = true;
            _held = null;
            await _begin(
              current.playlist,
              current.trackIndex,
              request_,
              paused: paused,
            );
          case _Apply.reload:
            unawaited(start(_resumeRequest(current), paused: paused));
        }
      // The playlist on its way was asked for with the old reciter or
      // quality: ask again. Repeat and speed are read once it arrives.
      case RecitationPreparing(:final request) when apply == _Apply.reload:
        unawaited(start(request));
      case RecitationPreparing() ||
          RecitationIdle() ||
          RecitationFailure() ||
          RecitationSuspended():
        break;
    }
    final saved = await _saveSettings(updated);
    return saved is ApiSuccess;
  }

  Future<void> _ensureSettings() => _settingsLoad ??= _loadSettings();

  Future<void> _loadSettings() async {
    final result = await _getSettings();
    if (isClosed) return;
    // The defaults stand in for settings that cannot be read.
    if (result case ApiSuccess(:final data)) emit(state.withSettings(data));
  }

  // ── player ──────────────────────────────────────────────────────────────

  /// Queues [playlist] from [index] as request [request_], held if
  /// [paused].
  Future<void> _begin(
    RecitationPlaylist playlist,
    int index,
    int request_, {
    bool paused = false,
  }) async {
    emit(
      RecitationActive(
        state.settings,
        playlist: playlist,
        trackIndex: index,
        status: RecitationStatus.loading,
      ),
    );
    final played = await _play(
      playlist,
      startIndex: index,
      settings: state.settings,
      paused: paused,
    );
    if (isClosed || request_ != _request) {
      // Stopped, closed or replaced while the player was being set up — so
      // what it was told may have started after it was told to stop. Unless
      // a newer playlist has reached the player since, silence it, so
      // nothing plays that no one can stop: standing by for one still on
      // its way, else for good.
      switch (state) {
        case _ when isClosed:
          unawaited(_stop());
        case RecitationPreparing():
          unawaited(_standBy());
        case RecitationIdle() || RecitationFailure() || RecitationSuspended():
          unawaited(_stop());
        case RecitationActive():
          break;
      }
      return;
    }
    if (played case ApiFailure(:final failure)) {
      return _fail(
        failure.message,
        RecitationOfScope(
          playlist.scope,
          startAyahId: playlist.tracks[index].ayahId,
        ),
      );
    }
    _starting = false;
    final held =
        _held ??
        (paused
            ? const RecitationPlayback(status: RecitationStatus.paused)
            : null);
    _held = null;
    // Only its status: the track it named may be the queue's it replaced,
    // while the new queue's track is known — the one just started.
    if (held != null) _onPlayback(RecitationPlayback(status: held.status));
  }

  /// Moves to [index], or back to the start of the ayah when it is the one
  /// on the player. The highlight moves at once, ahead of the player.
  Future<void> _skip(RecitationActive current, int index) async {
    if (index != current.trackIndex) emit(current.copyWith(trackIndex: index));
    if (await _skipTo(index) case ApiFailure(:final failure)) {
      _fail(failure.message, _resumeRequest(current));
    }
  }

  void _onPlayback(RecitationPlayback playback) {
    if (isClosed) return;
    if (_starting) {
      _held = playback;
      return;
    }
    final current = state;
    if (current is! RecitationActive) return;
    switch (playback.status) {
      case RecitationStatus.idle:
        // Only stop() empties the player, and it says so itself.
        return;
      case RecitationStatus.completed:
        unawaited(_onCompleted(current));
      case RecitationStatus.loading ||
          RecitationStatus.playing ||
          RecitationStatus.paused:
        final reported = playback.trackIndex;
        final index =
            reported != null &&
                    reported >= 0 &&
                    reported < current.playlist.tracks.length
                ? reported
                : current.trackIndex;
        if (index != current.trackIndex || playback.status != current.status) {
          final updated = current.copyWith(
            trackIndex: index,
            status: playback.status,
          );
          emit(updated);
          _prefetchNext(updated);
        }
    }
  }

  /// Carries on into the next part, or comes to rest.
  Future<void> _onCompleted(RecitationActive finished) async {
    final following = finished.playlist.scope.next;
    if (!finished.settings.continuous || following == null) {
      await stop();
      return;
    }
    await start(RecitationOfScope(following));
  }

  /// Fetches the next part while the last ayah plays, so it starts as soon
  /// as this one ends.
  void _prefetchNext(RecitationActive current) {
    final following = current.playlist.scope.next;
    if (!current.settings.continuous ||
        following == null ||
        following == _prefetched ||
        current.trackIndex != current.playlist.tracks.length - 1) {
      return;
    }
    _prefetched = following;
    unawaited(_load(RecitationOfScope(following), current.settings));
  }

  /// A control used outside the app — on the notification, the lock screen,
  /// headphones, a watch or a car — does what its button in the app does.
  void _onCommand(RecitationCommand command) {
    if (isClosed) return;
    final current = state;
    switch (command) {
      case RecitationCommand.play:
        switch (current) {
          case RecitationActive(status: RecitationStatus.paused):
            unawaited(resume());
          case RecitationFailure(:final request):
            unawaited(start(request));
          case RecitationSuspended(:final point):
            unawaited(start(point.request));
          case RecitationPreparing():
            _pausedWhilePreparing = null;
          case RecitationActive() || RecitationIdle():
            break;
        }
      case RecitationCommand.pause:
        switch (current) {
          case RecitationActive():
            unawaited(pause());
          // Between one part and the next: the next one comes paused.
          case RecitationPreparing():
            _pausedWhilePreparing = _request;
          case RecitationIdle() || RecitationFailure() || RecitationSuspended():
            break;
        }
      case RecitationCommand.next:
        unawaited(next());
      case RecitationCommand.previous:
        unawaited(previous());
      case RecitationCommand.stop:
        unawaited(stop());
    }
  }

  /// A recitation of the azkar took the player: whatever was recited, or
  /// offered to pick up again, is gone. The player is not this cubit's to
  /// stop any more.
  void _onTakenOver() {
    if (isClosed || state is RecitationIdle) return;
    _request++;
    _starting = false;
    _held = null;
    _pausedWhilePreparing = null;
    emit(RecitationIdle(state.settings));
  }

  void _onPlayerError(Object error) {
    final current = state;
    // While starting, the call to play reports the failure itself.
    if (isClosed || _starting || current is! RecitationActive) return;
    _fail(
      error is Failure ? error.message : FailureMessages.audio,
      _resumeRequest(current),
    );
  }

  void _fail(String message, RecitationRequest request) {
    _request++;
    _starting = false;
    emit(RecitationFailure(state.settings, message: message, request: request));
    unawaited(_stop());
  }

  /// Picks the recitation up again at the ayah it was on.
  static RecitationRequest _resumeRequest(RecitationActive current) =>
      RecitationOfScope(
        current.playlist.scope,
        startAyahId: current.currentTrack.ayahId,
      );

  /// Keeps where the recitation is as it moves on, and forgets it once the
  /// recitation is ended: stopped, finished, or replaced by the azkar. A
  /// failed one is kept, to be tried again.
  @override
  void onChange(Change<QuranRecitationState> change) {
    super.onChange(change);
    switch (change.nextState) {
      case RecitationActive(:final playlist, :final currentTrack):
        _resumePoint.write(
          RecitationResumePoint(scope: playlist.scope, track: currentTrack),
        );
      case RecitationIdle() when change.currentState is! RecitationIdle:
        _resumePoint.write(null);
      case RecitationIdle() ||
          RecitationPreparing() ||
          RecitationFailure() ||
          RecitationSuspended():
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
