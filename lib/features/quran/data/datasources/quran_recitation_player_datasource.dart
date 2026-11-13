import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/recitation.dart';
import 'quran_recitation_lengths_datasource.dart';
import 'quran_recitation_media_session.dart';
import 'quran_recitation_timeline.dart';

/// The player the Quran recitations stream on, one for all of them, so two
/// recitations of the Quran can never play over each other. It plays on
/// with the app in the background, shown with its controls on the
/// notification, the lock screen, a watch or a car — each surah as one
/// recitation, its progress bar spanning its ayahs in the queue.
class QuranRecitationPlayerDataSource {
  final QuranRecitationLengthsDataSource _lengths;

  AudioPlayer? _player;
  QuranRecitationMediaSession? _session;
  Future<void>? _sessionSetUp;
  Future<void>? _systemSetUp;

  /// The progress bars of [_timelineSequence], the queue the player holds.
  QuranRecitationTimeline? _timeline;
  List<IndexedAudioSource>? _timelineSequence;

  /// The lengths being read for a bar, one read at a time, and what calls
  /// it off.
  Future<void>? _lengthsRead;
  CancelToken? _lengthsCancel;

  /// The bar and entry the last read was for: one that failed is tried
  /// again only once the player is on another entry.
  (QuranRecitationTimeline, int)? _lengthsReadFor;

  QuranRecitationPlayerDataSource(this._lengths);

  /// The app's icon, as the recitation's artwork; null until copied to a
  /// file, the only place the system reads artwork from.
  Uri? _artUri;

  /// Bumped by every queue, [standBy] and [stop]: a queue that finishes
  /// loading after any of them was replaced while it loaded, and is not the
  /// one to show.
  var _queue = 0;

  /// Created on first use: the player claims platform resources.
  AudioPlayer get _instance => _player ??= _createPlayer();

  QuranRecitationMediaSession get _mediaSession =>
      _session ??= QuranRecitationMediaSession(
        pausePlayer: pause,
        stopPlayer: stop,
        seekPlayer: _seekOnBar,
      );

  Stream<PlayerState> get playerStates => _instance.playerStateStream;

  /// The entry of the queue being played.
  Stream<int?> get currentIndexes => _instance.currentIndexStream;

  /// Failures while loading or playing, which [playerStates] does not carry.
  Stream<PlayerException> get errors => _instance.errorStream;

  /// The controls used outside the app.
  Stream<RecitationCommand> get commands => _mediaSession.commands;

  /// Replaces the queue with [entries], each streamed from its
  /// [MediaItem.id] and shown outside the app as it says, played back to
  /// back without gaps from [initialIndex], each looped when [loopEach].
  /// Completes once the first entry has loaded and, unless [autoplay] is
  /// false, playback has been asked to start.
  ///
  /// Throws [PlayerException] when the first entry cannot be loaded, and
  /// [PlayerInterruptedException] when a newer queue replaces this one first.
  Future<void> playQueue(
    List<MediaItem> entries, {
    required int initialIndex,
    required bool loopEach,
    required double speed,
    bool autoplay = true,
  }) async {
    final queue = ++_queue;
    _lengthsCancel?.cancel();
    try {
      await (_setUpSession(), _setUpSystem()).wait;
      final player = _instance;
      await player.setLoopMode(loopEach ? LoopMode.one : LoopMode.off);
      await player.setSpeed(speed);
      await player.setAudioSources([
        for (final entry in entries)
          AudioSource.uri(Uri.parse(entry.id), tag: entry),
      ], initialIndex: initialIndex);
      if (autoplay) _start();
    } finally {
      // Read from the player, not its reports: those still on their way
      // say it is not playing yet, and the system would take the
      // notification out of the foreground for that moment.
      if (_player case final player? when queue == _queue) {
        _session?.release(_stateOf(player), _itemOf(player));
      }
    }
  }

  /// Nothing to do before anything has played.
  Future<void> pause() async => await _player?.pause();

  Future<void> resume() async => _start();

  /// Silences the player, keeping what the system shows up, as loading,
  /// until the next [playQueue].
  Future<void> standBy() async {
    _queue++;
    _lengthsCancel?.cancel();
    _session?.hold();
    await _player?.stop();
  }

  /// Silences the player and takes what the system shows down. Nothing to
  /// do before anything has played.
  Future<void> stop() async {
    _queue++;
    _lengthsCancel?.cancel();
    await _player?.stop();
    _session?.end();
  }

  /// Moves to the start of entry [index] of the queue.
  Future<void> seekToIndex(int index) async =>
      await _player?.seek(Duration.zero, index: index);

  Future<void> setSpeed(double speed) async => await _instance.setSpeed(speed);

  AudioPlayer _createPlayer() {
    final player = AudioPlayer();
    void showState(Object? _) => _mediaSession.showPlayer(_stateOf(player));
    void showItem(Object? _) {
      if (_itemOf(player) case final item?) _mediaSession.showItem(item);
      _readLengths(player);
    }

    player.playerEventStream.listen(showState, onError: _logReportError);
    player.sequenceStateStream.listen(showItem, onError: _logReportError);
    return player;
  }

  /// What the player is doing, its position placed on the bar of the part
  /// it is on once that bar is known.
  PlaybackState _stateOf(AudioPlayer player) {
    final event = player.playerEvent;
    final entry = event.playbackEvent.currentIndex;
    final timeline = _timelineOf(player);
    return QuranRecitationMediaSession.stateOf(
      event,
      speed: player.speed,
      offset:
          (entry == null ? null : timeline?.startOf(entry)) ?? Duration.zero,
    );
  }

  /// The entry the player is on, as long as the bar of its part; without a
  /// bar until that is known.
  MediaItem? _itemOf(AudioPlayer player) {
    final sequence = player.sequenceState;
    final entry = sequence.currentSource?.tag;
    if (entry is! MediaItem) return null;
    final index = sequence.currentIndex;
    return entry.copyWith(
      duration: index == null ? null : _timelineOf(player)?.lengthOfPart(index),
      artUri: _artUri,
    );
  }

  /// The progress bars of the queue the player holds, so they always match
  /// the entry it says it is on; built once for each queue.
  QuranRecitationTimeline? _timelineOf(AudioPlayer player) {
    final sequence = player.sequenceState.sequence;
    if (!identical(sequence, _timelineSequence)) {
      _timelineSequence = sequence;
      final entries = [
        for (final source in sequence)
          if (source.tag case final MediaItem entry) entry,
      ];
      _timeline =
          entries.length == sequence.length
              ? QuranRecitationTimeline(entries, _lengths.lengthOf)
              : null;
    }
    return _timeline;
  }

  /// Reads the lengths the bar of the part the player is on needs, then
  /// shows the bar — once the entry it plays is ready, so the reads never
  /// hold its own audio up. A read that fails is tried again at the next
  /// entry.
  void _readLengths(AudioPlayer player) {
    if (_lengthsRead != null ||
        player.processingState != ProcessingState.ready) {
      return;
    }
    final entry = player.sequenceState.currentIndex;
    final timeline = _timelineOf(player);
    if (entry == null ||
        timeline == null ||
        timeline.lengthOfPart(entry) != null ||
        _lengthsReadFor == (timeline, entry)) {
      return;
    }
    _lengthsReadFor = (timeline, entry);
    final cancel = _lengthsCancel = CancelToken();
    _lengthsRead = _lengths
        .read(timeline.urlsOfPart(entry), cancel: cancel)
        .whenComplete(() {
          _lengthsRead = null;
          if (cancel.isCancelled) {
            // Stopped or replaced while it was read: the bar of the new
            // queue, if any, instead.
            _readLengths(player);
            return;
          }
          _lengthsCancel = null;
          _mediaSession.showPlayer(_stateOf(player));
          if (_itemOf(player) case final item?) _mediaSession.showItem(item);
          // The player may have moved on to the next surah meanwhile.
          _readLengths(player);
        });
  }

  /// Moves to [position] on the bar of the part the player is on, into
  /// whichever of its ayahs it falls in; within the ayah while that bar is
  /// unknown. Nothing to do before anything has played.
  Future<void> _seekOnBar(Duration position) async {
    final player = _player;
    if (player == null) return;
    final entry = player.sequenceState.currentIndex;
    final target =
        entry == null ? null : _timelineOf(player)?.locate(entry, position);
    if (target == null) return player.seek(position);
    final (index, into) = target;
    await player.seek(into, index: index);
  }

  /// Tells the system a recitation is listened to like music: without it,
  /// iOS silences it with the ring switch and stops it when the screen
  /// locks. Done once; a failure is logged and tried again next time, as
  /// the recitation still plays without it.
  Future<void> _setUpSession() =>
      _sessionSetUp ??= () async {
        try {
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.music());
        } catch (error, stackTrace) {
          _sessionSetUp = null;
          log(
            'Quran audio session set-up failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }();

  /// Hands the recitation to the system, to show and control outside the
  /// app and, on Android, to keep playing in the background. Done once, as
  /// the system takes it only once; a failure is logged, and the
  /// recitation plays on in the app without it.
  Future<void> _setUpSystem() =>
      _systemSetUp ??= () async {
        await (_copyArt(), _startMediaSession()).wait;
      }();

  Future<void> _startMediaSession() async {
    try {
      await AudioService.init(
        builder: () => _mediaSession,
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'com.mishkat_almasabih.app.quran_recitation',
          androidNotificationChannelName: 'تلاوة القرآن',
          androidNotificationChannelDescription:
              'التلاوة الجارية وأزرار التحكم فيها',
          androidNotificationIcon: 'drawable/ic_stat_recitation',
          // Swiped away only once paused, as any audio player.
          androidNotificationOngoing: true,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Quran media session set-up failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _copyArt() async {
    try {
      final art = await rootBundle.load(_artAsset);
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/quran_recitation_art.png');
      await file.writeAsBytes(
        art.buffer.asUint8List(art.offsetInBytes, art.lengthInBytes),
        flush: true,
      );
      _artUri = file.uri;
    } catch (error, stackTrace) {
      log(
        'Quran recitation artwork unavailable',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static const _artAsset = 'assets/images/app_logo.png';

  /// `play()` completes only once playback stops, so it is not awaited; a
  /// failure while playing reaches listeners through [errors].
  void _start() {
    _instance.play().catchError(
      (Object error, StackTrace stackTrace) =>
          log('Quran playback failed', error: error, stackTrace: stackTrace),
    );
  }

  /// [errors] carries the player's failures to the app; the reports the
  /// system is shown can only be logged.
  static void _logReportError(Object error, StackTrace stackTrace) =>
      log('Quran player report failed', error: error, stackTrace: stackTrace);
}
