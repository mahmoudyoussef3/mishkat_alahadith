import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class DailyHadithRepo {
  Future<ExplainedHadith?> getSavedHadith();

  Future<ApiResult<ExplainedHadith>> fetchAndSaveHadith(String id);
}
