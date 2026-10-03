import 'package:mishkat_almasabih/core/networking/api_result.dart';

import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import '../repos/random_ahadith_repo.dart';

class GetRandomAhadithUseCase {
  final RandomAhadithRepo _repo;

  GetRandomAhadithUseCase(this._repo);

  Future<ApiResult<List<ExplainedHadith>>> call() => _repo.getRandomAhadith();
}
