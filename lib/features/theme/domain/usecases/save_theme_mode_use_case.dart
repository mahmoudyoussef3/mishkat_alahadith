import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/app_theme_mode.dart';
import '../repos/theme_repo.dart';

class SaveThemeModeUseCase {
  final ThemeRepo _repo;

  SaveThemeModeUseCase(this._repo);

  Future<ApiResult<void>> call(AppThemeMode mode) => _repo.saveThemeMode(mode);
}
