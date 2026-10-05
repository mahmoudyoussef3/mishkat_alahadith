import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/read_aloud_repo.dart';

class PauseSpeechUseCase {
  final ReadAloudRepo _repo;

  PauseSpeechUseCase(this._repo);

  /// False when the platform could not pause, so the caller must stop and
  /// later start again from where it was.
  Future<ApiResult<bool>> call() => _repo.pause();
}
