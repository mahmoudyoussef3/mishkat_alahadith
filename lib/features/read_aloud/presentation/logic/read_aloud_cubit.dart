import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/build_hadith_speech_track_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/export_hadith_audio_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/get_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/pause_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/prepare_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/resume_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/speak_text_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/stop_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_speech_events_use_case.dart';

part 'read_aloud_state.dart';

/// Reads hadiths aloud, one segment after another, following the engine's
/// callbacks.
///
/// The device has one speech engine, so the app has one of these: a
/// reading belongs to the screen that started it ([ReadAloudState.owner])
/// and a new one replaces it. Engine calls run one at a time, and every
/// change of position bumps a generation so that a late callback or timer
/// from before it is ignored.
class ReadAloudCubit extends Cubit<ReadAloudState> {
  ReadAloudCubit(
    this._buildTrack,
    this._prepare,
    this._getSettings,
    WatchReadAloudSettingsUseCase watchSettings,
    WatchSpeechEventsUseCase watchEvents,
    this._speak,
    this._pause,
    this._resume,
    this._stop,
    this._export,
  ) : super(const ReadAloudState()) {
    _eventsSubscription = watchEvents().listen(_onEvent);
    _settingsSubscription = watchSettings().listen(_onSettingsChanged);
  }

  final BuildHadithSpeechTrackUseCase _buildTrack;
  final PrepareSpeechUseCase _prepare;
  final GetReadAloudSettingsUseCase _getSettings;
  final SpeakTextUseCase _speak;
  final PauseSpeechUseCase _pause;
  final ResumeSpeechUseCase _resume;
  final StopSpeechUseCase _stop;
  final ExportHadithAudioUseCase _export;
  late final StreamSubscription<SpeechEvent> _eventsSubscription;
  late final StreamSubscription<ReadAloudSettings> _settingsSubscription;

  /// Read to try a voice: the opening of the first hadith of al-Bukhari.
  static const previewText =
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ. قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ '
      'عَلَيْهِ وَسَلَّمَ: إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ '
      'امْرِئٍ مَا نَوَى.';

  /// "Previous" restarts the segment being read once this far into it.
  static const _restartAfter = 12;

  ReadAloudSettings _settings = ReadAloudSettings.defaults;
  bool _settingsLoaded = false;

  /// The settings the engine was last set up with.
  ReadAloudSettings? _preparedFor;
  int _generation = 0;

  /// The generation the engine's current utterance was started in.
  int _utterance = -1;

  /// From asking the engine to speak until it reports it started; a
  /// completion in between belongs to an earlier utterance.
  bool _awaitingStart = false;

  /// The engine holds the paused utterance and can carry on with it.
  bool _enginePaused = false;

  /// Where in the current segment's spoken text the reading has reached.
  int _offset = 0;
  Timer? _gapTimer;
  Future<void> _queue = Future.value();
  int _noticeId = 0;

  bool get _isPrepared => _preparedFor?.soundsLike(_settings) ?? false;

  /// Reads [request] for [owner]. When [owner] paused this very reading, it
  /// carries on instead of starting over.
  Future<void> play(Object owner, HadithSpeechRequest request) {
    final current = state;
    final same = current.ownedBy(owner) && current.track?.key == request.key;
    if (same && current.status == ReadAloudStatus.paused) return resume();
    if (same && current.isPlaying) return Future.value();

    final generation = _bump();
    _awaitingStart = true;
    return _serial(() => _start(generation, owner, request));
  }

  Future<void> pause() {
    if (!state.isPlaying) return Future.value();
    final generation = _bump();
    final speaking = !_awaitingStart && state.status == ReadAloudStatus.playing;
    _awaitingStart = false;
    emit(state.copyWith(status: ReadAloudStatus.paused));
    return _serial(() async {
      if (generation != _generation || isClosed) return;
      _enginePaused = false;
      if (speaking) {
        final paused = await _pause();
        if (generation != _generation || isClosed) return;
        _enginePaused = paused is ApiSuccess<bool> && paused.data;
      }
      // Covers an engine that cannot pause, and one that started speaking
      // before reporting it.
      if (!_enginePaused) await _stop();
    });
  }

  Future<void> resume() {
    if (state.status != ReadAloudStatus.paused || state.track == null) {
      return Future.value();
    }
    final generation = _bump();
    final native = _enginePaused;
    final offset = _offset;
    _awaitingStart = true;
    emit(state.copyWith(status: ReadAloudStatus.playing, previewing: false));
    return _serial(() async {
      if (generation != _generation || isClosed) return;
      // A voice change since the pause means starting the utterance over.
      if (native && _isPrepared) {
        _utterance = generation;
        final resumed = await _resume();
        if (generation != _generation || isClosed) return;
        if (resumed is ApiSuccess) return;
      }
      await _speakSegment(generation, offset);
    });
  }

  Future<void> togglePlayPause() => state.isPlaying ? pause() : resume();

  Future<void> next() => _skip(1);

  /// Back to the start of the part being read, or to the part before when
  /// already at its start.
  Future<void> previous() => _skip(-1);

  Future<void> stop() {
    _bump();
    _awaitingStart = false;
    _enginePaused = false;
    emit(const ReadAloudState());
    return _serial(() => _stop(release: true));
  }

  /// Stops the reading if [owner] started it, e.g. when its screen closes.
  Future<void> release(Object owner) =>
      state.ownedBy(owner) ? stop() : Future.value();

  /// Pauses the reading if [owner] started it, e.g. when its screen is
  /// covered.
  Future<void> interrupt(Object owner) =>
      state.ownedBy(owner) && state.isPlaying ? pause() : Future.value();

  /// Reads a short sample with the current voice. A reading in progress
  /// pauses, to carry on from the same word.
  Future<void> preview({Object? owner}) {
    final generation = _bump();
    _awaitingStart = true;
    _enginePaused = false;
    final current = state;
    emit(
      ReadAloudState(
        owner: current.owner ?? owner,
        track: current.track,
        index: current.index,
        status:
            current.isPlaying ? ReadAloudStatus.paused : current.status,
        spokenOffset: current.spokenOffset,
        word: current.word,
        previewing: true,
        exporting: current.exporting,
        notice: current.notice,
      ),
    );
    return _serial(() async {
      if (generation != _generation || isClosed) return;
      await _ensureSettings();
      if (!await _ensurePrepared(generation)) return;
      _utterance = generation;
      final spoken = await _speak(previewText);
      if (generation != _generation || isClosed) return;
      if (spoken case ApiFailure(:final failure)) _fail(failure.message);
    });
  }

  /// Records [request] to an audio file and returns its path. A reading in
  /// progress pauses: recording needs the engine.
  Future<ApiResult<String>> exportAudio(HadithSpeechRequest request) {
    if (state.exporting) {
      return Future.value(const ApiResult.failure(SpeechFailure()));
    }
    if (state.isPlaying) pause();
    emit(state.copyWith(exporting: true));
    return _serial(() async {
      await _ensureSettings();
      final result = await _export(request, _settings);
      // Recording stops whatever the engine held and sets the voice up
      // itself; the next reading starts afresh.
      _enginePaused = false;
      _preparedFor = null;
      if (!isClosed) emit(state.copyWith(exporting: false));
      return result;
    });
  }

  Future<void> _start(
    int generation,
    Object owner,
    HadithSpeechRequest request,
  ) async {
    if (generation != _generation || isClosed) return;
    await _ensureSettings();
    final track = _buildTrack(request, _settings);
    if (generation != _generation || isClosed) return;
    if (track.isEmpty) {
      _awaitingStart = false;
      return;
    }
    // Whatever was read before, by this screen or another, ends here.
    await _stop();
    emit(
      ReadAloudState(
        owner: owner,
        track: track,
        status: ReadAloudStatus.preparing,
        notice: state.notice,
      ),
    );
    await _speakSegment(generation, 0);
  }

  Future<void> _skip(int step) {
    final track = state.track;
    if (track == null || !state.isActive) return Future.value();
    final completed = state.status == ReadAloudStatus.completed;
    var target = state.index + step;
    if (step < 0 && (completed || state.spokenOffset > _restartAfter)) {
      target = state.index;
    }
    if (target < 0 || target >= track.segments.length) return Future.value();
    if (completed && step > 0) return Future.value();
    return _jumpTo(target);
  }

  /// Reads the whole reading again from its start.
  Future<void> restart() =>
      state.isActive ? _jumpTo(0) : Future.value();

  Future<void> _jumpTo(int target) {
    final generation = _bump();
    _awaitingStart = true;
    _enginePaused = false;
    emit(
      state.copyWith(
        index: target,
        spokenOffset: 0,
        clearWord: true,
        status: ReadAloudStatus.playing,
        previewing: false,
      ),
    );
    return _serial(() => _speakSegment(generation, 0));
  }

  /// Reads the current segment from its [offset]th character.
  Future<void> _speakSegment(int generation, int offset) async {
    if (generation != _generation || isClosed) return;
    if (!await _ensurePrepared(generation)) return;
    final segment = state.segment;
    if (segment == null) return;
    final from = offset.clamp(0, segment.spoken.length);
    _awaitingStart = true;
    _enginePaused = false;
    _utterance = generation;
    _offset = from;
    if (state.status == ReadAloudStatus.preparing) {
      emit(state.copyWith(status: ReadAloudStatus.playing));
    }
    final spoken = await _speak(segment.spoken.substring(from));
    if (generation != _generation || isClosed) return;
    if (spoken case ApiFailure(:final failure)) _fail(failure.message);
  }

  Future<void> _advance(int generation) async {
    if (generation != _generation || isClosed) return;
    final track = state.track;
    if (track == null) return;
    final next = state.index + 1;
    if (next >= track.segments.length) {
      _awaitingStart = false;
      emit(
        state.copyWith(
          status: ReadAloudStatus.completed,
          spokenOffset: track.segments.last.spoken.length,
          clearWord: true,
        ),
      );
      await _stop(release: true);
      return;
    }

    final gap = _gapBetween(track.segments[state.index], track.segments[next]);
    emit(state.copyWith(index: next, spokenOffset: 0, clearWord: true));
    _offset = 0;
    if (gap == Duration.zero) return _speakSegment(generation, 0);
    _gapTimer = Timer(gap, () {
      if (generation == _generation && !isClosed) {
        _serial(() => _speakSegment(generation, 0));
      }
    });
  }

  /// No pause inside one text split for length; the chosen pause between
  /// different parts.
  Duration _gapBetween(SpeechSegment previous, SpeechSegment next) =>
      previous.part == next.part && previous.item == next.item
          ? Duration.zero
          : _settings.partGap.duration;

  void _onEvent(SpeechEvent event) {
    if (isClosed) return;
    switch (event) {
      case SpeechStarted() || SpeechResumed():
        _awaitingStart = false;
      case SpeechProgress():
        _onProgress(event);
      case SpeechCompleted():
        _onCompleted();
      case SpeechFailed():
        _onFailed();
      // Our own pause and stop cause these, and the state already shows it.
      case SpeechPaused() || SpeechCancelled():
        break;
    }
  }

  void _onProgress(SpeechProgress event) {
    final current = state;
    if (current.previewing ||
        (current.status != ReadAloudStatus.playing &&
            current.status != ReadAloudStatus.paused)) {
      return;
    }
    final segment = current.segment;
    if (segment == null) return;
    // Positions are in the text the engine holds, which after starting
    // from a word, or an Android pause, is the rest of the segment. Any
    // other text is a late report from an earlier utterance.
    final spoken = segment.spoken;
    if (event.text.length > spoken.length || !spoken.endsWith(event.text)) {
      return;
    }
    final base = spoken.length - event.text.length;
    final start = base + event.start;
    final end = base + event.end;
    if (start < 0 || end > spoken.length || start >= end) return;

    _offset = start;
    final word = segment.sourceRange(start, end);
    emit(
      current.copyWith(spokenOffset: start, word: word, clearWord: word == null),
    );
  }

  void _onCompleted() {
    if (state.previewing) {
      if (_utterance == _generation) {
        _awaitingStart = false;
        emit(state.copyWith(previewing: false));
      }
      return;
    }
    if (state.status != ReadAloudStatus.playing ||
        _awaitingStart ||
        _utterance != _generation) {
      return;
    }
    final generation = _bump();
    _awaitingStart = true;
    _serial(() => _advance(generation));
  }

  void _onFailed() {
    if (!state.previewing && state.status != ReadAloudStatus.playing) return;
    _bump();
    _fail(const SpeechFailure().message);
  }

  /// Shows [message]; a reading under way pauses so play retries it.
  void _fail(String message) {
    _awaitingStart = false;
    _enginePaused = false;
    final current = state;
    final notice = ReadAloudNotice(++_noticeId, message, owner: current.owner);
    if (current.track == null || current.status == ReadAloudStatus.preparing) {
      emit(ReadAloudState(notice: notice));
    } else {
      emit(
        current.copyWith(
          status:
              current.status == ReadAloudStatus.completed
                  ? ReadAloudStatus.completed
                  : ReadAloudStatus.paused,
          previewing: false,
          notice: notice,
        ),
      );
    }
  }

  /// A voice, speed or engine change is heard from the current word on.
  void _onSettingsChanged(ReadAloudSettings settings) {
    final before = _settings;
    _settings = settings;
    _settingsLoaded = true;
    if (isClosed ||
        settings.soundsLike(before) ||
        state.status != ReadAloudStatus.playing ||
        state.previewing ||
        _awaitingStart) {
      return;
    }
    final generation = _bump();
    final offset = _offset;
    _awaitingStart = true;
    _serial(() => _speakSegment(generation, offset));
  }

  Future<void> _ensureSettings() async {
    if (_settingsLoaded) return;
    final result = await _getSettings();
    if (result case ApiSuccess(:final data)) _settings = data;
    _settingsLoaded = true;
  }

  Future<bool> _ensurePrepared(int generation) async {
    if (_isPrepared) return true;
    final settings = _settings;
    final result = await _prepare(settings);
    if (generation != _generation || isClosed) return false;
    switch (result) {
      case ApiSuccess():
        _preparedFor = settings;
        return true;
      case ApiFailure(:final failure):
        _fail(failure.message);
        return false;
    }
  }

  int _bump() {
    _gapTimer?.cancel();
    _gapTimer = null;
    return ++_generation;
  }

  /// Runs [action] after every action queued before it.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  @override
  Future<void> close() async {
    _bump();
    await _eventsSubscription.cancel();
    await _settingsSubscription.cancel();
    await _stop(release: true);
    return super.close();
  }
}
