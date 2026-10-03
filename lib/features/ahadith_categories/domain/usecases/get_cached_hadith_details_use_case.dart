import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import '../repos/categories_repository.dart';

class GetCachedHadithDetailsUseCase {
  final CategoriesRepository _repo;

  GetCachedHadithDetailsUseCase(this._repo);

  Future<ExplainedHadith?> call(String id) => _repo.getCachedHadithDetails(id);
}
