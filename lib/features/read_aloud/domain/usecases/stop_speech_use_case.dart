import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/read_aloud_repo.dart';

class StopSpeechUseCase {
  final ReadAloudRepo _repo;

  StopSpeechUseCase(this._repo);

  /// With [release], audio is handed back to other apps as well.
  Future<ApiResult<void>> call({bool release = false}) =>
      _repo.stop(release: release);
}
