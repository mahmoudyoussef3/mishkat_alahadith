import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_font_scale.dart';
import '../repos/reading_preferences_repo.dart';

class SaveHadithFontScaleUseCase {
  final ReadingPreferencesRepo _repo;

  SaveHadithFontScaleUseCase(this._repo);

  Future<ApiResult<void>> call(HadithFontScale scale) =>
      _repo.saveHadithFontScale(scale);
}
