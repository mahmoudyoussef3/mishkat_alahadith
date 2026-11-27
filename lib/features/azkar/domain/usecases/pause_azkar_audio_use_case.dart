import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

class PauseAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  PauseAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.pause();
}
