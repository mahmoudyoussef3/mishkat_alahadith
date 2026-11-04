import 'dart:developer';

import 'package:just_audio/just_audio.dart';

/// One player for every recitation, so two can never play over each other.
class AzkarAudioPlayerDataSource {
  AudioPlayer? _player;

  /// Created on first use: the player claims platform resources.
  AudioPlayer get _instance => _player ??= AudioPlayer();

  Stream<PlayerState> get playerStates => _instance.playerStateStream;

  /// Failures while loading or playing, which [playerStates] does not carry.
  Stream<PlayerException> get errors => _instance.errorStream;

  Future<void> playFile(String path) async {
    await _instance.setFilePath(path);
    _start();
  }

  /// Nothing to do before anything has played.
  Future<void> pause() async => await _player?.pause();

  Future<void> resume() async => _start();

  /// Nothing to do before anything has played.
  Future<void> stop() async => await _player?.stop();

  /// `play()` completes only once playback stops, so it is not awaited; a
  /// failure while playing reaches listeners through [errors].
  void _start() {
    _instance.play().catchError(
      (Object error, StackTrace stackTrace) =>
          log('Azkar playback failed', error: error, stackTrace: stackTrace),
    );
  }
}
