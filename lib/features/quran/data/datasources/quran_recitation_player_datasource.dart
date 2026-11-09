import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// The player the Quran recitations stream on, one for all of them, so two
/// recitations of the Quran can never play over each other.
class QuranRecitationPlayerDataSource {
  AudioPlayer? _player;
  Future<void>? _sessionSetUp;

  /// Created on first use: the player claims platform resources.
  AudioPlayer get _instance => _player ??= AudioPlayer();

  Stream<PlayerState> get playerStates => _instance.playerStateStream;

  /// The entry of the queue being played.
  Stream<int?> get currentIndexes => _instance.currentIndexStream;

  /// Failures while loading or playing, which [playerStates] does not carry.
  Stream<PlayerException> get errors => _instance.errorStream;

  /// Replaces the queue with [urls], played back to back without gaps from
  /// [initialIndex], each entry looped when [loopEach]. Completes once the
  /// first entry has loaded and, unless [autoplay] is false, playback has
  /// been asked to start.
  ///
  /// Throws [PlayerException] when the first entry cannot be loaded, and
  /// [PlayerInterruptedException] when a newer queue replaces this one first.
  Future<void> playQueue(
    List<String> urls, {
    required int initialIndex,
    required bool loopEach,
    required double speed,
    bool autoplay = true,
  }) async {
    await _setUpSession();
    final player = _instance;
    await player.setLoopMode(loopEach ? LoopMode.one : LoopMode.off);
    await player.setSpeed(speed);
    await player.setAudioSources([
      for (final url in urls) AudioSource.uri(Uri.parse(url)),
    ], initialIndex: initialIndex);
    if (autoplay) _start();
  }

  /// Nothing to do before anything has played.
  Future<void> pause() async => await _player?.pause();

  Future<void> resume() async => _start();

  /// Nothing to do before anything has played.
  Future<void> stop() async => await _player?.stop();

  /// Moves to the start of entry [index] of the queue.
  Future<void> seekToIndex(int index) async =>
      await _player?.seek(Duration.zero, index: index);

  Future<void> setSpeed(double speed) async => await _instance.setSpeed(speed);

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

  /// `play()` completes only once playback stops, so it is not awaited; a
  /// failure while playing reaches listeners through [errors].
  void _start() {
    _instance.play().catchError(
      (Object error, StackTrace stackTrace) =>
          log('Quran playback failed', error: error, stackTrace: stackTrace),
    );
  }
}
