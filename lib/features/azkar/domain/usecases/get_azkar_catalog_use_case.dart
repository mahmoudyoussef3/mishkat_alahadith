import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_category.dart';
import '../entities/azkar_settings.dart';
import '../repos/azkar_repo.dart';

/// Every chapter of Hisn Al-Muslim, in source order.
class GetAzkarCatalogUseCase {
  final AzkarRepo _repo;

  GetAzkarCatalogUseCase(this._repo);

  Future<ApiResult<List<AzkarCategory>>> call(AzkarTranslation translation) =>
      _repo.getCategories(translation);
}
