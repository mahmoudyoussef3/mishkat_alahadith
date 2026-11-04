import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

class PlayAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  PlayAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call(String localPath) => _repo.play(localPath);
}
