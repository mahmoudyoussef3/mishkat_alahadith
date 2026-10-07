import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/read_aloud_repo.dart';

class ResumeSpeechUseCase {
  final ReadAloudRepo _repo;

  ResumeSpeechUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.resume();
}
