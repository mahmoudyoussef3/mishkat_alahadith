import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

class StopAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  StopAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.stop();
}
