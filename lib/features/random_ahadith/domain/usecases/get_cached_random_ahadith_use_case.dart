import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';

import '../repos/random_ahadith_repo.dart';

class GetCachedRandomAhadithUseCase {
  final RandomAhadithRepo _repo;

  GetCachedRandomAhadithUseCase(this._repo);

  Future<List<ExplainedHadith>?> call() => _repo.getCachedRandomAhadith();
}
