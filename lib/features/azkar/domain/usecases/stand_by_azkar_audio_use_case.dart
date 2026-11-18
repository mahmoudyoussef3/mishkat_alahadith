import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

/// Takes the player, silenced, while a recitation downloads — so whatever
/// played, the Quran included, stops at once.
class StandByAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  StandByAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.standBy();
}
