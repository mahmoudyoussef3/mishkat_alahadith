import 'package:mishkat_almasabih/core/networking/categories_api_service.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_by_category_model.dart';

abstract class CategoriesDatasource {
  Future<List<CategoryModel>> getCategories();
  Future<HadithByCategoryResponseModel> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  });
}

class CategoriesDatasourceImpl implements CategoriesDatasource {
  final CategoryApiService _apiService;

  CategoriesDatasourceImpl(this._apiService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await _apiService.getCategories();
  }

  @override
  Future<HadithByCategoryResponseModel> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  }) async {
    return await _apiService.getAhadithByCategory(
      categoryId: categoryId,
      page: page,
      perPage: perPage,
    );
  }
}
