import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_audio.dart';

/// The recitations of Hisn Al-Muslim: fetched once, kept on the device, and
/// played on the app's one player, shared with the Quran — so two
/// recitations can never overlap. They play on with the app in the
/// background, shown with their controls outside the app.
abstract class AzkarAudioRepo {
  /// Makes [audioFile] ready to play offline, downloading it the first time,
  /// and succeeds with where it is kept.
  Future<ApiResult<String>> prepare(String audioFile);

  /// Plays the file at [localPath] from the start, replacing whatever was
  /// playing; outside the app it is named as [track] is.
  Future<ApiResult<void>> play(String localPath, AzkarAudioTrack track);

  Future<ApiResult<void>> pause();

  Future<ApiResult<void>> resume();

  /// Takes the player and silences it while the next recitation is on its
  /// way. Unlike [stop], the controls outside the app stay up, showing it
  /// loading.
  Future<ApiResult<void>> standBy();

  /// Silences the player and takes its controls outside the app down,
  /// unless the Quran has taken it since.
  Future<ApiResult<void>> stop();

  Stream<AzkarPlaybackStatus> watchStatus();

  /// The controls used outside the app while a recitation of the azkar
  /// plays: on the notification, the lock screen, headphones, a watch or a
  /// car.
  Stream<MediaCommand> commands();

  /// Each time something else — a recitation of the Quran — takes the
  /// player: the recitation is gone from it, and calls made since do
  /// nothing until the next [standBy] or [play].
  Stream<void> takenOver();

  /// The recitation the app was last closed on, if it was not ended.
  Future<ApiResult<AzkarAudioTrack?>> getLastTrack();

  /// Keeps [track] for after the app is closed; null forgets the one kept.
  Future<ApiResult<void>> saveLastTrack(AzkarAudioTrack? track);
}
