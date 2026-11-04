import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_audio.dart';

/// The recitations of Hisn Al-Muslim: fetched once, kept on the device, and
/// played on a single player shared by the whole app.
abstract class AzkarAudioRepo {
  /// Makes [audioFile] ready to play offline, downloading it the first time,
  /// and succeeds with where it is kept.
  Future<ApiResult<String>> prepare(String audioFile);

  /// Plays the file at [localPath] from the start, replacing whatever was
  /// playing.
  Future<ApiResult<void>> play(String localPath);

  Future<ApiResult<void>> pause();

  Future<ApiResult<void>> resume();

  Future<ApiResult<void>> stop();

  Stream<AzkarPlaybackStatus> watchStatus();
}
