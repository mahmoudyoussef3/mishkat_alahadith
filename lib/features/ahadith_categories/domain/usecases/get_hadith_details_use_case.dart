import 'package:mishkat_almasabih/core/networking/api_result.dart';

import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import '../repos/categories_repository.dart';

class GetHadithDetailsUseCase {
  final CategoriesRepository _repo;

  GetHadithDetailsUseCase(this._repo);

  Future<ApiResult<ExplainedHadith>> call(String id) =>
      _repo.getHadithDetails(id);
}
