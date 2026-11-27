import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/azkar_repo.dart';

/// Adds the chapter to the favourites if it is not there, removes it if it
/// is.
///
/// Succeeds with `true` when the chapter is now a favourite, `false` when it
/// was removed.
class ToggleFavoriteAzkarUseCase {
  final AzkarRepo _repo;

  ToggleFavoriteAzkarUseCase(this._repo);

  Future<ApiResult<bool>> call(int categoryId) async {
    var added = false;
    final result = await _repo.updateFavoriteIds((ids) {
      added = !ids.contains(categoryId);
      return added
          ? [categoryId, ...ids]
          : ids.where((id) => id != categoryId).toList();
    });
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess() => ApiResult.success(added),
    };
  }
}
