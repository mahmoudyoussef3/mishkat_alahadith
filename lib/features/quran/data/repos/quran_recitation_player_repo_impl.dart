import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/recitation.dart';
import '../../domain/entities/recitation_settings.dart';
import '../../domain/repos/quran_recitation_player_repo.dart';
import '../datasources/quran_recitation_player_datasource.dart';

class QuranRecitationPlayerRepoImpl implements QuranRecitationPlayerRepo {
  final QuranRecitationPlayerDataSource _player;

  /// The track each entry of the player's queue plays. A repeated ayah is
  /// queued as many times as it is repeated, back to back, so repetition is
  /// as gapless as the move to the next ayah.
  List<int> _entryTracks = const [];

  /// The entry of [_entryTracks] the player last said it is on; forgotten
  /// when the queue is replaced, so an entry of the old queue is never read
  /// as one of the new.
  int? _currentEntry;

  QuranRecitationPlayerRepoImpl(this._player);

  @override
  Future<ApiResult<void>> play(
    List<RecitationTrack> tracks, {
    required String reciterName,
    required int startIndex,
    required AyahRepeat repeat,
    required RecitationSpeed speed,
    bool paused = false,
  }) {
    if (tracks.isEmpty || startIndex < 0 || startIndex >= tracks.length) {
      return Future.value(
        const ApiResult.failure(UnexpectedFailure(FailureMessages.audio)),
      );
    }
    // Endless repetition loops the one entry instead.
    final times = repeat.times ?? 1;
    final queue = <MediaItem>[];
    final entries = <int>[];
    for (var track = 0; track < tracks.length; track++) {
      final item = mediaItemOf(tracks[track], reciterName);
      for (var i = 0; i < times; i++) {
        queue.add(item);
        entries.add(track);
      }
    }
    _entryTracks = List.unmodifiable(entries);
    _currentEntry = null;
    return _guard(
      () => _player.playQueue(
        queue,
        initialIndex: startIndex * times,
        loopEach: repeat.times == null,
        speed: speed.factor,
        autoplay: !paused,
      ),
    );
  }

  @override
  Future<ApiResult<void>> pause() => _guard(_player.pause);

  @override
  Future<ApiResult<void>> resume() => _guard(_player.resume);

  @override
  Future<ApiResult<void>> standBy() => _guard(_player.standBy);

  @override
  Future<ApiResult<void>> stop() => _guard(_player.stop);

  @override
  Future<ApiResult<void>> skipTo(int index) {
    final entry = _entryTracks.indexOf(index);
    if (entry < 0) {
      return Future.value(
        const ApiResult.failure(UnexpectedFailure(FailureMessages.audio)),
      );
    }
    return _guard(() => _player.seekToIndex(entry));
  }

  @override
  Future<ApiResult<void>> setSpeed(RecitationSpeed speed) =>
      _guard(() => _player.setSpeed(speed.factor));

  @override
  Stream<RecitationPlayback> watch() {
    StreamSubscription<PlayerState>? states;
    StreamSubscription<int?>? indexes;
    StreamSubscription<PlayerException>? errors;
    late final StreamController<RecitationPlayback> controller;
    PlayerState? lastState;
    RecitationPlayback? lastSent;

    void send() {
      final state = lastState;
      if (state == null) return;
      final entry = _currentEntry;
      final playback = RecitationPlayback(
        status: statusOf(state),
        trackIndex:
            entry != null && entry >= 0 && entry < _entryTracks.length
                ? _entryTracks[entry]
                : null,
      );
      if (playback == lastSent) return;
      lastSent = playback;
      controller.add(playback);
    }

    void fail(Object error, [StackTrace? stackTrace]) {
      log('Quran player error', error: error, stackTrace: stackTrace);
      controller.addError(const UnexpectedFailure(FailureMessages.audio));
    }

    controller = StreamController(
      onListen: () {
        states = _player.playerStates.listen((state) {
          lastState = state;
          send();
        }, onError: fail);
        indexes = _player.currentIndexes.listen((entry) {
          _currentEntry = entry;
          send();
        }, onError: fail);
        errors = _player.errors.listen(fail, onError: fail);
      },
      onCancel: () async {
        await states?.cancel();
        await indexes?.cancel();
        await errors?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Stream<RecitationCommand> commands() => _player.commands;

  /// [track] as the system shows it outside the app, streamed from its
  /// [MediaItem.id]: by its surah, the ayahs of which share one title and
  /// so one progress bar.
  static MediaItem mediaItemOf(RecitationTrack track, String reciterName) =>
      MediaItem(
        id: track.url,
        title: track.surahTitle,
        artist: reciterName,
        album: 'القرآن الكريم',
      );

  static RecitationStatus statusOf(PlayerState state) => switch (state
      .processingState) {
    ProcessingState.idle => RecitationStatus.idle,
    ProcessingState.loading ||
    ProcessingState.buffering => RecitationStatus.loading,
    ProcessingState.ready =>
      state.playing ? RecitationStatus.playing : RecitationStatus.paused,
    ProcessingState.completed => RecitationStatus.completed,
  };

  Future<ApiResult<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const ApiResult.success(null);
    } catch (error, stackTrace) {
      log('Quran player failed', error: error, stackTrace: stackTrace);
      return const ApiResult.failure(UnexpectedFailure(FailureMessages.audio));
    }
  }
}
