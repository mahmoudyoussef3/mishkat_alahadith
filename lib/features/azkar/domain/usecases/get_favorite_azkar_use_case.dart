import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_repo.dart';

/// Favourite chapter ids, most recently added first.
class GetFavoriteAzkarUseCase {
  final AzkarRepo _repo;

  GetFavoriteAzkarUseCase(this._repo);

  Future<ApiResult<List<int>>> call() => _repo.getFavoriteIds();
}
