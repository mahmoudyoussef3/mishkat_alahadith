import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

class ResumeAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  ResumeAzkarAudioUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.resume();
}
