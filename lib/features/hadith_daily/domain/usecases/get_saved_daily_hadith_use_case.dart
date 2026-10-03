import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

import '../repos/daily_hadith_repo.dart';

class GetSavedDailyHadithUseCase {
  final DailyHadithRepo _repo;

  GetSavedDailyHadithUseCase(this._repo);

  Future<ExplainedHadith?> call() => _repo.getSavedHadith();
}
