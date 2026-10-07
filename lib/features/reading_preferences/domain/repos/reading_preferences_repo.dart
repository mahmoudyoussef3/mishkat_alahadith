import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_font_scale.dart';

abstract class ReadingPreferencesRepo {
  Future<ApiResult<HadithFontScale>> getHadithFontScale();

  Future<ApiResult<void>> saveHadithFontScale(HadithFontScale scale);
}
