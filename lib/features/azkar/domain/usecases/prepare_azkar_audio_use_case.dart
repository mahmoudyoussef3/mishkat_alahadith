import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_audio_repo.dart';

/// Makes a recitation playable offline, downloading it the first time.
class PrepareAzkarAudioUseCase {
  final AzkarAudioRepo _repo;

  PrepareAzkarAudioUseCase(this._repo);

  Future<ApiResult<String>> call(String audioFile) => _repo.prepare(audioFile);
}
