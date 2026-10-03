import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_ayah.dart';
import '../entities/quran_surah.dart';
import '../entities/tajweed_info.dart';

/// The bundled mushaf text: surahs, ayahs and their tajweed.
abstract class QuranRepo {
  Future<ApiResult<List<QuranSurah>>> getSurahs();

  Future<ApiResult<List<QuranAyah>>> getAllAyahs();

  Future<ApiResult<List<QuranAyah>>> getPageAyahs(int page);

  Future<ApiResult<QuranAyah>> getAyah(int ayahId);

  Future<ApiResult<List<TajweedSegment>>> getAyahTajweed(
    int ayahId, {
    required bool includeNaturalMadd,
  });

  /// Most frequent rule first.
  Future<ApiResult<List<TajweedRuleCount>>> getPageTajweedCounts(
    int page, {
    required bool includeNaturalMadd,
  });
}
