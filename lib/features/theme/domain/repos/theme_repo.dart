import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/app_theme_mode.dart';

abstract class ThemeRepo {
  Future<ApiResult<AppThemeMode>> getThemeMode();

  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode);
}
