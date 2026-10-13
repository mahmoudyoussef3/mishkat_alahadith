import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/read_aloud_settings.dart';
import '../repos/read_aloud_repo.dart';

class SaveReadAloudSettingsUseCase {
  final ReadAloudRepo _repo;

  SaveReadAloudSettingsUseCase(this._repo);

  Future<ApiResult<void>> call(ReadAloudSettings settings) =>
      _repo.saveSettings(settings.normalized());
}
