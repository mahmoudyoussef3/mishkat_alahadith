import 'dart:math';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_ayah.dart';
import '../entities/quran_commentary.dart';
import '../entities/quran_surah.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_cloud_repo.dart';
import '../repos/quran_repo.dart';
import 'get_ayah_commentary_use_case.dart';

/// A surah's ayahs with their tafsir and translation, a page at a time: a
/// long tafsir of a long surah runs to megabytes.
class GetSurahCommentaryUseCase {
  static const int pageSize = 10;

  final QuranCloudRepo _cloud;
  final QuranRepo _quran;

  GetSurahCommentaryUseCase(this._cloud, this._quran);

  /// The page of [surahNumber] that starts [offset] ayahs in, from 0.
  Future<ApiResult<SurahCommentaryPage>> call(
    int surahNumber,
    CommentarySettings settings, {
    int offset = 0,
  }) async {
    final ids = settings.editionIds;
    if (!ids.every(RecitationSettings.isValidEditionId)) {
      return const ApiResult.failure(UnexpectedFailure());
    }

    final QuranSurah surah;
    switch (await _quran.getSurahs()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: final surahs):
        final found = QuranSurah.numbered(surahs, surahNumber);
        if (found == null || offset < 0 || offset >= found.ayahCount) {
          return const ApiResult.failure(UnexpectedFailure());
        }
        surah = found;
    }

    final (textsResult, ayahsResult) =
        await (
          _cloud.getSurahTexts(
            surahNumber,
            ids,
            offset: offset,
            limit: pageSize,
          ),
          _quran.getAllAyahs(),
        ).wait;

    switch ((textsResult, ayahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final texts), ApiSuccess(data: final ayahs)):
        // Every edition's passage for an ayah, the ayahs in mushaf order.
        final grouped = <int, List<EditionText>>{};
        for (final entry in texts) {
          (grouped[entry.ayahId] ??= []).add(entry.text);
        }
        final ayahIds = grouped.keys.toList()..sort();
        // The service answers nothing for a request it could not serve —
        // an unknown edition, a page past the end.
        if (texts.isEmpty) return const ApiResult.failure(ServerFailure());
        final commented = [
          for (final id in ayahIds)
            if (QuranAyah.withId(ayahs, id) case final ayah?
                when ayah.surahNumber == surahNumber)
              CommentedAyah(
                ayah: ayah,
                surah: surah,
                commentary: GetAyahCommentaryUseCase.commentaryOf(
                  id,
                  grouped[id]!,
                  settings,
                ),
              ),
        ];
        return ApiResult.success(
          SurahCommentaryPage(
            surah: surah,
            ayahs: List.unmodifiable(commented),
            offset: offset,
            nextOffset: min(offset + pageSize, surah.ayahCount),
          ),
        );
    }
  }
}
