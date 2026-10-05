import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_font_scale.dart';
import '../repos/reading_preferences_repo.dart';

class GetHadithFontScaleUseCase {
  final ReadingPreferencesRepo _repo;

  GetHadithFontScaleUseCase(this._repo);

  Future<ApiResult<HadithFontScale>> call() => _repo.getHadithFontScale();
}
