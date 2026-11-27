import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/read_aloud_repo.dart';

class SpeakTextUseCase {
  final ReadAloudRepo _repo;

  SpeakTextUseCase(this._repo);

  Future<ApiResult<void>> call(String text) => _repo.speak(text);
}
