import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_settings.dart';
import '../repos/azkar_repo.dart';

class GetAzkarSettingsUseCase {
  final AzkarRepo _repo;

  GetAzkarSettingsUseCase(this._repo);

  Future<ApiResult<AzkarSettings>> call() => _repo.getSettings();
}
