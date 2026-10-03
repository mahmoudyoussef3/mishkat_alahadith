import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/app_theme_mode.dart';
import '../repos/theme_repo.dart';

class GetThemeModeUseCase {
  final ThemeRepo _repo;

  GetThemeModeUseCase(this._repo);

  Future<ApiResult<AppThemeMode>> call() => _repo.getThemeMode();
}
