import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_ayah.dart';
import '../entities/quran_edition_search.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_cloud_repo.dart';
import '../repos/quran_repo.dart';
import '../services/text_excerpt.dart';

/// Searches the words of a tafsir or translation rather than the mushaf —
/// so «الربا» finds the ayahs about usury whatever words they use.
class SearchQuranEditionUseCase {
  static const int minQueryLength = 2;
  static const int pageSize = 20;

  final QuranCloudRepo _cloud;
  final QuranRepo _quran;

  SearchQuranEditionUseCase(this._cloud, this._quran);

  bool canSearch(String query) => query.trim().length >= minQueryLength;

  /// The page of results that starts [offset] matches in, from 0.
  Future<ApiResult<EditionSearchPage>> call(
    String query,
    String editionId, {
    int offset = 0,
  }) async {
    final trimmed = query.trim();
    if (!canSearch(trimmed)) {
      return ApiResult.success(_empty(trimmed, editionId, offset));
    }
    if (!RecitationSettings.isValidEditionId(editionId) || offset < 0) {
      return const ApiResult.failure(UnexpectedFailure());
    }

    final (matchesResult, ayahsResult, surahsResult) =
        await (
          _cloud.searchEdition(
            trimmed,
            editionId,
            offset: offset,
            limit: pageSize,
          ),
          _quran.getAllAyahs(),
          _quran.getSurahs(),
        ).wait;

    switch ((matchesResult, ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _, _):
      case (_, ApiFailure(:final failure), _):
      case (_, _, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (
        ApiSuccess(data: final found),
        ApiSuccess(data: final ayahs),
        ApiSuccess(data: final surahs),
      ):
        final surahNames = {for (final s in surahs) s.number: s.nameArabic};
        final hits = <EditionSearchHit>[];
        for (final match in found.matches) {
          final ayah = QuranAyah.withId(ayahs, match.ayahId);
          if (ayah == null) continue;
          final excerpt = TextExcerpts.around(match.text, trimmed);
          hits.add(
            EditionSearchHit(
              ayah: ayah,
              surahName: surahNames[ayah.surahNumber] ?? '',
              excerpt: excerpt.text,
              matches: excerpt.matches,
            ),
          );
        }
        return ApiResult.success(
          EditionSearchPage(
            query: trimmed,
            editionId: editionId,
            hits: List.unmodifiable(hits),
            total: found.total,
            offset: offset,
            fetched: found.matches.length,
          ),
        );
    }
  }

  static EditionSearchPage _empty(String query, String editionId, int offset) =>
      EditionSearchPage(
        query: query,
        editionId: editionId,
        hits: const [],
        total: 0,
        offset: offset,
        fetched: 0,
      );
}
