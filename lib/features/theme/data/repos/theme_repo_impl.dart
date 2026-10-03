import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repos/theme_repo.dart';
import '../datasources/theme_local_datasource.dart';

class ThemeRepoImpl implements ThemeRepo {
  final ThemeLocalDataSource _local;

  ThemeRepoImpl(this._local);

  @override
  Future<ApiResult<AppThemeMode>> getThemeMode() async {
    try {
      final stored = await _local.getThemeMode();
      final mode = AppThemeMode.values.asNameMap()[stored];
      return ApiResult.success(mode ?? AppThemeMode.light);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode) async {
    try {
      await _local.saveThemeMode(mode.name);
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }
}
