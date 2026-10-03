import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/category_entity.dart';
import '../entities/hadith_entity.dart';

abstract class CategoriesRepository {
  Future<ApiResult<List<CategoryEntity>>> getCategories();

  Future<ApiResult<HadithResponseEntity>> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  });

  Future<ExplainedHadith?> getCachedHadithDetails(String id);

  Future<ApiResult<ExplainedHadith>> getHadithDetails(String id);
}
