import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_settings.dart';
import '../repos/azkar_repo.dart';

class SaveAzkarSettingsUseCase {
  final AzkarRepo _repo;

  SaveAzkarSettingsUseCase(this._repo);

  Future<ApiResult<void>> call(AzkarSettings settings) =>
      _repo.saveSettings(settings);
}
