import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_repo.dart';

import '../entities/ayah_reference.dart';
import '../entities/daily_ayah.dart';
import '../repos/daily_ayah_repo.dart';
import '../services/daily_ayah_rotation.dart';

/// The ayahs featured on a run of days.
class GetDailyAyahsUseCase {
  final DailyAyahRepo _repo;
  final QuranRepo _quranRepo;

  GetDailyAyahsUseCase(this._repo, this._quranRepo);

  /// One ayah for each of [days] days in a row, the first being the calendar
  /// day of [from].
  Future<ApiResult<List<DailyAyah>>> call({
    required DateTime from,
    int days = 1,
  }) async {
    final (catalog, surahs, ayahs) =
        await (
          _repo.getCatalog(),
          _quranRepo.getSurahs(),
          _quranRepo.getAllAyahs(),
        ).wait;

    return switch ((catalog, surahs, ayahs)) {
      (
        ApiSuccess(data: final catalog),
        ApiSuccess(data: final surahs),
        ApiSuccess(data: final ayahs),
      ) =>
        _pick(catalog, surahs, ayahs, from: from, days: days),
      (ApiFailure(:final failure), _, _) ||
      (_, ApiFailure(:final failure), _) ||
      (_, _, ApiFailure(:final failure)) => ApiResult.failure(failure),
    };
  }

  ApiResult<List<DailyAyah>> _pick(
    List<AyahReference> catalog,
    List<QuranSurah> surahs,
    List<QuranAyah> ayahs, {
    required DateTime from,
    required int days,
  }) {
    if (catalog.isEmpty) return const ApiResult.failure(UnexpectedFailure());

    final byReference = {
      for (final a in ayahs) AyahReference(a.surahNumber, a.number): a,
    };
    final picked = <DailyAyah>[];
    for (var offset = 0; offset < days; offset++) {
      // Built from the date, not by adding hours, so a daylight saving
      // change can never skip or repeat a day.
      final day = DateTime(from.year, from.month, from.day + offset);
      final reference =
          catalog[DailyAyahRotation.indexFor(day, catalog.length)];
      final ayah = byReference[reference];
      final surah = QuranSurah.numbered(surahs, reference.surah);
      // The catalog is checked against the mushaf in tests, so a miss means
      // broken data: better no ayah than a gap in the days.
      if (ayah == null || surah == null) {
        return const ApiResult.failure(UnexpectedFailure());
      }
      picked.add(DailyAyah(day: day, ayah: ayah, surah: surah));
    }
    return ApiResult.success(picked);
  }
}
