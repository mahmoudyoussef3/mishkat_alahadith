import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/audio/app_audio_player.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

/// The azkar's hold on the app's one player, which every recitation —
/// Quran or azkar — plays on, so two can never play over each other.
///
/// Calls made after the Quran took the player do nothing, and only what
/// the player reports while reciting the azkar is heard here.
class AzkarAudioPlayerDataSource {
  final AppAudioPlayer _player;

  AzkarAudioPlayerDataSource(this._player);

  Stream<PlayerState> get playerStates => _player.playerStatesOf(this);

  /// Failures while loading or playing, which [playerStates] does not carry.
  Stream<PlayerException> get errors => _player.errorsOf(this);

  /// The controls used outside the app while the azkar are recited.
  Stream<MediaCommand> get commands => _player.commandsOf(this);

  /// Each time the Quran takes the player: the recitation, or the one offered
  /// to play again, is gone.
  Stream<void> get takeovers => _player.takeoversOf(this);

  /// Plays the file [item] names by its [MediaItem.id], a `file:` URI, from
  /// the start, shown outside the app as [item] says.
  Future<void> playFile(MediaItem item) => _player.playQueue(
    this,
    [item],
    initialIndex: 0,
    loopEach: false,
    speed: 1,
    // One recitation, nothing to skip to.
    skippable: false,
  );

  Future<void> pause() => _player.pause(this);

  Future<void> resume() => _player.resume(this);

  /// Takes the player and silences it, keeping what the system shows up,
  /// as loading, until the next [playFile].
  Future<void> standBy() => _player.standBy(this);

  /// Silences the player and takes what the system shows down, unless the
  /// Quran has taken it since.
  Future<void> stop() => _player.stop(this);
}
