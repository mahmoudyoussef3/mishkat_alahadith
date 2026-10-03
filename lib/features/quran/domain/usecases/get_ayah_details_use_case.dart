import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/ayah_details.dart';
import '../repos/quran_repo.dart';

/// One ayah with its surah and tajweed, for the ayah sheet.
class GetAyahDetailsUseCase {
  final QuranRepo _repo;

  GetAyahDetailsUseCase(this._repo);

  Future<ApiResult<AyahDetails>> call(
    int ayahId, {
    required bool includeNaturalMadd,
  }) async {
    final results =
        await (
          _repo.getAyah(ayahId),
          _repo.getSurahs(),
          _repo.getAyahTajweed(ayahId, includeNaturalMadd: includeNaturalMadd),
        ).wait;

    switch (results) {
      case (ApiFailure(:final failure), _, _):
      case (_, ApiFailure(:final failure), _):
      case (_, _, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (
        ApiSuccess(data: final ayah),
        ApiSuccess(data: final surahs),
        ApiSuccess(data: final tajweed),
      ):
        final surah =
            surahs.where((s) => s.number == ayah.surahNumber).firstOrNull;
        if (surah == null) return const ApiResult.failure(UnexpectedFailure());
        return ApiResult.success(
          AyahDetails(ayah: ayah, surah: surah, tajweed: tajweed),
        );
    }
  }
}
