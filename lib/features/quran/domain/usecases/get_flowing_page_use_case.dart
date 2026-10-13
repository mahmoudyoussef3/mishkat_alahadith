import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_flowing_page.dart';
import '../entities/quran_metrics.dart';
import '../entities/quran_surah.dart';
import '../entities/tajweed_info.dart';
import '../repos/quran_repo.dart';

/// A page's ayahs as running text, grouped by surah, each with its tajweed.
class GetFlowingPageUseCase {
  final QuranRepo _repo;

  GetFlowingPageUseCase(this._repo);

  Future<ApiResult<QuranFlowingPage>> call(
    int page, {
    required bool includeNaturalMadd,
  }) async {
    if (!QuranMetrics.isValidPage(page)) {
      return const ApiResult.failure(UnexpectedFailure());
    }

    final (ayahsResult, surahsResult) =
        await (_repo.getPageAyahs(page), _repo.getSurahs()).wait;

    switch ((ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final ayahs), ApiSuccess(data: final surahs)):
        if (ayahs.isEmpty) return const ApiResult.failure(UnexpectedFailure());

        final tajweedResults = await [
          for (final ayah in ayahs)
            _repo.getAyahTajweed(
              ayah.id,
              includeNaturalMadd: includeNaturalMadd,
            ),
        ].wait;

        final sections = <QuranFlowingSection>[];
        QuranSurah? surah;
        var ayahsOfSurah = <QuranFlowingAyah>[];
        void closeSection() {
          final current = surah;
          if (current == null || ayahsOfSurah.isEmpty) return;
          sections.add(
            QuranFlowingSection(
              surah: current,
              opensHere: ayahsOfSurah.first.ayah.number == 1,
              ayahs: List.unmodifiable(ayahsOfSurah),
            ),
          );
        }

        for (var i = 0; i < ayahs.length; i++) {
          final ayah = ayahs[i];
          final List<TajweedSegment> tajweed;
          switch (tajweedResults[i]) {
            case ApiFailure(:final failure):
              return ApiResult.failure(failure);
            case ApiSuccess(:final data):
              tajweed = data;
          }
          if (surah?.number != ayah.surahNumber) {
            closeSection();
            surah = QuranSurah.numbered(surahs, ayah.surahNumber);
            if (surah == null) {
              return const ApiResult.failure(UnexpectedFailure());
            }
            ayahsOfSurah = [];
          }
          ayahsOfSurah.add(QuranFlowingAyah(ayah: ayah, tajweed: tajweed));
        }
        closeSection();

        return ApiResult.success(
          QuranFlowingPage(page: page, sections: List.unmodifiable(sections)),
        );
    }
  }
}
