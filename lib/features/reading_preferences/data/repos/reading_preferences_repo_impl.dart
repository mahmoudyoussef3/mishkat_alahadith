import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/hadith_font_scale.dart';
import '../../domain/repos/reading_preferences_repo.dart';
import '../datasources/reading_preferences_local_datasource.dart';

class ReadingPreferencesRepoImpl implements ReadingPreferencesRepo {
  final ReadingPreferencesLocalDataSource _local;

  ReadingPreferencesRepoImpl(this._local);

  @override
  Future<ApiResult<HadithFontScale>> getHadithFontScale() async {
    try {
      final stored = await _local.getHadithFontScale();
      final scale = HadithFontScale.values.asNameMap()[stored];
      return ApiResult.success(scale ?? HadithFontScale.medium);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveHadithFontScale(HadithFontScale scale) async {
    try {
      await _local.saveHadithFontScale(scale.name);
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }
}
