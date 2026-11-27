import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_audio.dart';
import '../repos/azkar_audio_repo.dart';

/// The recitation the app was last closed on, if it was not ended; null
/// when there is nothing to pick up.
class GetLastAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  GetLastAzkarAudioUseCase(this._repo);

  Future<ApiResult<AzkarAudioTrack?>> call() => _repo.getLastTrack();
}

/// Keeps the recitation on the player, to offer it again after the app is
/// closed; null once it is ended, so nothing is offered.
class SaveLastAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  SaveLastAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call(AzkarAudioTrack? track) =>
      _repo.saveLastTrack(track);
}
