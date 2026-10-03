import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_metrics.dart';
import '../entities/quran_page_info.dart';
import '../entities/quran_surah.dart';
import '../repos/quran_repo.dart';

/// The surahs and juz a page belongs to — what its header shows.
class GetPageInfoUseCase {
  final QuranRepo _repo;

  GetPageInfoUseCase(this._repo);

  Future<ApiResult<QuranPageInfo>> call(int page) async {
    if (!QuranMetrics.isValidPage(page)) {
      return const ApiResult.failure(UnexpectedFailure());
    }

    final ayahsResult = await _repo.getPageAyahs(page);
    final surahsResult = await _repo.getSurahs();

    switch ((ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final ayahs), ApiSuccess(data: final surahs)):
        if (ayahs.isEmpty) return const ApiResult.failure(UnexpectedFailure());

        final surahByNumber = <int, QuranSurah>{
          for (final surah in surahs) surah.number: surah,
        };
        final onPage = <QuranSurah>[];
        for (final ayah in ayahs) {
          final surah = surahByNumber[ayah.surahNumber];
          if (surah != null && !onPage.contains(surah)) onPage.add(surah);
        }
        if (onPage.isEmpty) return const ApiResult.failure(UnexpectedFailure());

        return ApiResult.success(
          QuranPageInfo(
            page: page,
            juz: ayahs.first.juz,
            surahs: onPage,
            firstAyahId: ayahs.first.id,
            lastAyahId: ayahs.last.id,
          ),
        );
    }
  }
}
