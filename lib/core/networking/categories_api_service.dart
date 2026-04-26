import 'package:dio/dio.dart';
import 'package:mishkat_almasabih/core/networking/api_constants.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_by_category_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
part 'categories_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.hadithCategoriesBaseApi)
abstract class CategoryApiService {
  factory CategoryApiService(Dio dio, {String baseUrl}) = _CategoryApiService;

  @GET(ApiConstants.getCategories)
  Future<List<CategoryModel>> getCategories();

  @GET(ApiConstants.getAhadithByCategory)
  Future<HadithByCategoryResponseModel> getAhadithByCategory({
    @Query('language') String language = 'ar',
    @Query('category_id') required String categoryId,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });
}
