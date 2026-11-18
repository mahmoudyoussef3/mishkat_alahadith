import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:path_provider/path_provider.dart';

import 'app_media_session.dart';
import 'audio_lengths_datasource.dart';
import 'audio_timeline.dart';

/// The app's one player: every recitation — of the Quran or of the azkar —
/// plays on it, so two can never play over each other, and starting one
/// replaces whatever was playing. It plays on with the app in the
/// background or swiped away, shown with its controls on the notification,
/// the lock screen, a watch or a car — each part of a queue, such as the
/// ayahs of a surah, as one recitation, its progress bar spanning them.
///
/// It plays for one owner at a time — whoever queued or stood it by last —
/// and only the owner's calls reach it: a late call from one it was taken
/// from does nothing. Each owner hears only what the player reports while
/// playing for it, and is told through [takeoversOf] when another takes
/// it.
class AppAudioPlayer {
  final AudioLengthsDataSource _lengths;

  AudioPlayer? _player;
  AppMediaSession? _session;
  Future<void>? _sessionSetUp;
  Future<void>? _systemSetUp;

  /// Who the player plays for; null once stopped.
  Object? _holder;

  /// Whether the queue on the player has entries to skip between, as the
  /// ayahs of a surah have; the system then offers previous and next.
  var _skippable = true;

  /// The progress bars of [_timelineSequence], the queue the player holds.
  AudioTimeline? _timeline;
  List<IndexedAudioSource>? _timelineSequence;

  /// The lengths being read for a bar, one read at a time, and what calls
  /// it off.
  Future<void>? _lengthsRead;
  CancelToken? _lengthsCancel;

  /// The bar and entry the last read was for: one that failed is tried
  /// again only once the player is on another entry.
  (AudioTimeline, int)? _lengthsReadFor;

  /// The app's icon, as the recitation's artwork; null until copied to a
  /// file, the only place the system reads artwork from.
  Uri? _artUri;

  /// Bumped by every queue, stand-by and stop: a queue that finishes
  /// loading after any of them was replaced while it loaded, and is not the
  /// one to play or show.
  var _queue = 0;

  // What the player reports, each with who it was playing for then.
  final _states = StreamController<(Object?, PlayerState)>.broadcast();
  final _indexes = StreamController<(Object?, int?)>.broadcast();
  final _errors = StreamController<(Object?, PlayerException)>.broadcast();

  /// Each owner the player was taken for.
  final _claims = StreamController<Object>.broadcast();

  AppAudioPlayer(this._lengths);

  /// Created on first use: the player claims platform resources.
  AudioPlayer get _instance => _player ??= _createPlayer();

  AppMediaSession get _mediaSession =>
      _session ??= AppMediaSession(
        pausePlayer: _pauseAny,
        stopPlayer: _stopAny,
        seekPlayer: _seekOnBar,
      )..holder = _holder;

  /// What the system is shown, and whose its controls are.
  @visibleForTesting
  AppMediaSession get mediaSession => _mediaSession;

  /// What the player is doing while it plays for [owner].
  Stream<PlayerState> playerStatesOf(Object owner) =>
      _states.stream.transform(_reportsFor(owner));

  /// The entry of [owner]'s queue being played.
  Stream<int?> currentIndexesOf(Object owner) =>
      _indexes.stream.transform(_reportsFor(owner));

  /// Failures while loading or playing for [owner], which
  /// [playerStatesOf] does not carry.
  Stream<PlayerException> errorsOf(Object owner) =>
      _errors.stream.transform(_reportsFor(owner));

  /// The controls used outside the app while the player plays for [owner].
  Stream<MediaCommand> commandsOf(Object owner) =>
      _mediaSession.commandsOf(owner);

  /// Each time another owner takes the player, whether or not [owner] had
  /// it: whatever [owner] played, or offered to play again, is gone.
  Stream<void> takeoversOf(Object owner) =>
      _claims.stream.where((claimer) => !identical(claimer, owner));

  /// Plays for [owner] from now on, taking the player from whoever had it.
  /// Replaces the queue with [entries], each streamed from its
  /// [MediaItem.id] and shown outside the app as it says, played back to
  /// back without gaps from [initialIndex], each looped when [loopEach].
  /// Previous and next are offered outside the app only when [skippable].
  /// Completes once the first entry has loaded and, unless [autoplay] is
  /// false, playback has been asked to start.
  ///
  /// Throws [PlayerException] when the first entry cannot be loaded, and
  /// [PlayerInterruptedException] when a newer queue replaces this one while
  /// it loads; one stopped or replaced before it loads is left unloaded.
  Future<void> playQueue(
    Object owner,
    List<MediaItem> entries, {
    required int initialIndex,
    required bool loopEach,
    required double speed,
    bool autoplay = true,
    bool skippable = true,
  }) async {
    _claim(owner);
    final queue = ++_queue;
    _lengthsCancel?.cancel();
    _skippable = skippable;
    try {
      await (_setUpSession(), _setUpSystem()).wait;
      // Stopped or replaced meanwhile — on the first queue, the set-up may
      // take a while: the player is left to whoever has it now.
      if (queue != _queue) return;
      final player = _instance;
      await player.setLoopMode(loopEach ? LoopMode.one : LoopMode.off);
      if (queue != _queue) return;
      await player.setSpeed(speed);
      if (queue != _queue) return;
      await player.setAudioSources([
        for (final entry in entries)
          AudioSource.uri(Uri.parse(entry.id), tag: entry),
      ], initialIndex: initialIndex);
      // Replaced while it loaded, possibly by another owner's queue still
      // on its way: never started over it.
      if (autoplay && queue == _queue) _start();
    } finally {
      // Read from the player, not its reports: those still on their way
      // say it is not playing yet, and the system would take the
      // notification out of the foreground for that moment.
      if (_player case final player? when queue == _queue) {
        _session?.release(_stateOf(player), _itemOf(player));
      }
    }
  }

  Future<void> pause(Object owner) async {
    if (_holds(owner)) await _player?.pause();
  }

  Future<void> resume(Object owner) async {
    if (_holds(owner)) _start();
  }

  /// Takes the player for [owner] and silences it, keeping what the system
  /// shows up, as loading, until [owner]'s next [playQueue].
  Future<void> standBy(Object owner) async {
    _claim(owner);
    _queue++;
    _lengthsCancel?.cancel();
    _session?.hold();
    await _player?.stop();
  }

  /// Silences the player and takes what the system shows down, if it still
  /// plays for [owner].
  Future<void> stop(Object owner) async {
    if (_holds(owner)) await _stopAny();
  }

  /// Moves to the start of entry [index] of [owner]'s queue.
  Future<void> seekToIndex(Object owner, int index) async {
    if (_holds(owner)) await _player?.seek(Duration.zero, index: index);
  }

  Future<void> setSpeed(Object owner, double speed) async {
    if (_holds(owner)) await _player?.setSpeed(speed);
  }

  bool _holds(Object owner) => identical(_holder, owner);

  void _claim(Object owner) {
    _holder = owner;
    _session?.holder = owner;
    _claims.add(owner);
  }

  /// Passes on only what was reported while the player played for
  /// [owner]; its errors too, while it still does.
  StreamTransformer<(Object?, T), T> _reportsFor<T>(Object owner) =>
      StreamTransformer.fromHandlers(
        handleData: (report, sink) {
          if (identical(report.$1, owner)) sink.add(report.$2);
        },
        handleError: (error, stackTrace, sink) {
          if (_holds(owner)) sink.addError(error, stackTrace);
        },
      );

  /// For a control used outside the app while no one plays for the
  /// holder. Nothing to do before anything has played.
  Future<void> _pauseAny() async => await _player?.pause();

  Future<void> _stopAny() async {
    final queue = ++_queue;
    _lengthsCancel?.cancel();
    await _player?.stop();
    // Taken by another owner meanwhile: what is shown is theirs now.
    if (queue != _queue) return;
    _session?.end();
    _holder = null;
    _session?.holder = null;
  }

  AudioPlayer _createPlayer() {
    final player = AudioPlayer();
    void showState(Object? _) => _mediaSession.showPlayer(_stateOf(player));
    void showItem(Object? _) {
      if (_itemOf(player) case final item?) _mediaSession.showItem(item);
      _readLengths(player);
    }

    player.playerEventStream.listen(showState, onError: _logReportError);
    player.sequenceStateStream.listen(showItem, onError: _logReportError);
    // A file's own length is known only once it has loaded.
    player.durationStream.listen(showItem, onError: _logReportError);

    player.playerStateStream.listen(
      (state) => _states.add((_holder, state)),
      onError: _states.addError,
    );
    player.currentIndexStream.listen(
      (index) => _indexes.add((_holder, index)),
      onError: _indexes.addError,
    );
    player.errorStream.listen(
      (error) => _errors.add((_holder, error)),
      onError: _errors.addError,
    );
    return player;
  }

  /// What the player is doing, its position placed on the bar of the part
  /// it is on once that bar is known.
  PlaybackState _stateOf(AudioPlayer player) {
    final event = player.playerEvent;
    final entry = event.playbackEvent.currentIndex;
    final timeline = _timelineOf(player);
    return AppMediaSession.stateOf(
      event,
      speed: player.speed,
      offset:
          (entry == null ? null : timeline?.startOf(entry)) ?? Duration.zero,
      skippable: _skippable,
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
  AudioTimeline? _timelineOf(AudioPlayer player) {
    final sequence = player.sequenceState.sequence;
    if (!identical(sequence, _timelineSequence)) {
      _timelineSequence = sequence;
      final entries = [
        for (final source in sequence)
          if (source.tag case final MediaItem entry) entry,
      ];
      _timeline =
          entries.length == sequence.length
              ? AudioTimeline(entries, _lengthOf)
              : null;
    }
    return _timeline;
  }

  /// A streamed file's length once read from its head; a file on the
  /// device, the length the player found once it is on it.
  Duration? _lengthOf(String url) {
    if (_isStreamed(url)) return _lengths.lengthOf(url);
    final player = _player;
    final current = player?.sequenceState.currentSource?.tag;
    return current is MediaItem && current.id == url ? player?.duration : null;
  }

  static bool _isStreamed(String url) =>
      url.startsWith('https://') || url.startsWith('http://');

  /// Reads the lengths the bar of the part the player is on needs, then
  /// shows the bar — once the entry it plays is ready, so the reads never
  /// hold its own audio up. A read that fails is tried again at the next
  /// entry. Files on the device need no read.
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
        _lengthsReadFor == (timeline, entry) ||
        !timeline.urlsOfPart(entry).every(_isStreamed)) {
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
          // The player may have moved on to the next part meanwhile.
          _readLengths(player);
        });
  }

  /// Moves to [position] on the bar of the part the player is on, into
  /// whichever of its entries it falls in; within the entry while that bar
  /// is unknown. Nothing to do before anything has played.
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
            'Recitation audio session set-up failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }();

  /// Hands the player to the system, to show and control outside the app
  /// and, on Android, to keep playing in the background. Done once, as the
  /// system takes it only once; a failure is logged, and the recitation
  /// plays on in the app without it.
  Future<void> _setUpSystem() =>
      _systemSetUp ??= () async {
        await (_copyArt(), _startMediaSession()).wait;
      }();

  Future<void> _startMediaSession() async {
    try {
      await AudioService.init(
        builder: () => _mediaSession,
        config: const AudioServiceConfig(
          // Kept from when only the Quran played here, so the channel the
          // listener may have set up stays theirs.
          androidNotificationChannelId:
              'com.mishkat_almasabih.app.quran_recitation',
          androidNotificationChannelName: 'التلاوة',
          androidNotificationChannelDescription:
              'تلاوة القرآن والأذكار الجارية وأزرار التحكم فيها',
          androidNotificationIcon: 'drawable/ic_stat_recitation',
          // Swiped away only once paused, as any audio player.
          androidNotificationOngoing: true,
        ),
      );
    } catch (error, stackTrace) {
      log(
        'Recitation media session set-up failed',
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
        'Recitation artwork unavailable',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static const _artAsset = 'assets/images/app_logo.png';

  /// `play()` completes only once playback stops, so it is not awaited; a
  /// failure while playing reaches the owner through [errorsOf].
  void _start() {
    _instance.play().catchError(
      (Object error, StackTrace stackTrace) =>
          log('Playback failed', error: error, stackTrace: stackTrace),
    );
  }

  /// [errorsOf] carries the player's failures to its owner; the reports
  /// the system is shown can only be logged.
  static void _logReportError(Object error, StackTrace stackTrace) =>
      log('Player report failed', error: error, stackTrace: stackTrace);
}
