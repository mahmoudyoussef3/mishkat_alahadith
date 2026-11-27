import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/audio/app_audio_player.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

import '../../domain/entities/recitation.dart';

/// The Quran's hold on the app's one player, which every recitation —
/// Quran or azkar — plays on, so two can never play over each other. It
/// plays on with the app in the background, shown with its controls on the
/// notification, the lock screen, a watch or a car — each surah as one
/// recitation, its progress bar spanning its ayahs in the queue.
///
/// Calls made after the azkar took the player do nothing, and only what
/// the player reports while reciting the Quran is heard here.
class QuranRecitationPlayerDataSource {
  final AppAudioPlayer _player;

  QuranRecitationPlayerDataSource(this._player);

  Stream<PlayerState> get playerStates => _player.playerStatesOf(this);

  /// The entry of the queue being played.
  Stream<int?> get currentIndexes => _player.currentIndexesOf(this);

  /// Failures while loading or playing, which [playerStates] does not carry.
  Stream<PlayerException> get errors => _player.errorsOf(this);

  /// The controls used outside the app while the Quran is recited.
  Stream<RecitationCommand> get commands =>
      _player.commandsOf(this).map(_recitationCommandOf);

  /// Each time the azkar take the player: the recitation, or the one offered
  /// to play again, is gone.
  Stream<void> get takeovers => _player.takeoversOf(this);

  /// Replaces whatever the player plays with [entries], each streamed from
  /// its [MediaItem.id] and shown outside the app as it says, played back
  /// to back without gaps from [initialIndex], each looped when [loopEach].
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
  }) => _player.playQueue(
    this,
    entries,
    initialIndex: initialIndex,
    loopEach: loopEach,
    speed: speed,
    autoplay: autoplay,
  );

  Future<void> pause() => _player.pause(this);

  Future<void> resume() => _player.resume(this);

  /// Takes the player and silences it, keeping what the system shows up,
  /// as loading, until the next [playQueue].
  Future<void> standBy() => _player.standBy(this);

  /// Silences the player and takes what the system shows down, unless the
  /// azkar have taken it since.
  Future<void> stop() => _player.stop(this);

  /// Moves to the start of entry [index] of the queue.
  Future<void> seekToIndex(int index) => _player.seekToIndex(this, index);

  RecitationProgress? get progress => _player.entryProgressOf(this);

  Future<void> seek(String url, Duration position) =>
      _player.seekInEntry(this, url, position);

  Future<void> setSpeed(double speed) => _player.setSpeed(this, speed);

  static RecitationCommand _recitationCommandOf(MediaCommand command) =>
      switch (command) {
        MediaCommand.play => RecitationCommand.play,
        MediaCommand.pause => RecitationCommand.pause,
        MediaCommand.next => RecitationCommand.next,
        MediaCommand.previous => RecitationCommand.previous,
        MediaCommand.stop => RecitationCommand.stop,
      };
}
