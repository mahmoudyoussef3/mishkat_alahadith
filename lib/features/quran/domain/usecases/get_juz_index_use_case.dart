import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_juz.dart';
import '../entities/quran_surah.dart';
import '../repos/quran_repo.dart';

/// The thirty ajzāʾ, each with the page and ayah it opens on.
class GetJuzIndexUseCase {
  final QuranRepo _repo;

  GetJuzIndexUseCase(this._repo);

  Future<ApiResult<List<QuranJuz>>> call() async {
    final ayahsResult = await _repo.getAllAyahs();
    final surahsResult = await _repo.getSurahs();

    switch ((ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final ayahs), ApiSuccess(data: final surahs)):
        final surahByNumber = <int, QuranSurah>{
          for (final surah in surahs) surah.number: surah,
        };
        final juzList = <QuranJuz>[];
        var lastJuz = 0;
        for (final ayah in ayahs) {
          if (ayah.juz == lastJuz) continue;
          lastJuz = ayah.juz;
          juzList.add(
            QuranJuz(
              number: ayah.juz,
              startPage: ayah.page,
              startSurahNumber: ayah.surahNumber,
              startSurahName: surahByNumber[ayah.surahNumber]?.nameArabic ?? '',
              startAyahNumber: ayah.number,
            ),
          );
        }
        return ApiResult.success(juzList);
    }
  }
}
