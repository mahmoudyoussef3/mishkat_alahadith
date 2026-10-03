import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_hadith_repo.dart';

class FetchDailyHadithUseCase {
  final DailyHadithRepo _repo;

  FetchDailyHadithUseCase(this._repo);

  Future<ApiResult<ExplainedHadith>> call(String id) =>
      _repo.fetchAndSaveHadith(id);
}
