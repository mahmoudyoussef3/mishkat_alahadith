import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_commentary.dart';
import '../entities/quran_edition.dart';
import '../entities/quran_edition_search.dart';
import '../entities/quran_hizb_quarter.dart';
import '../entities/recitation.dart';

/// The online Quran service (AlQuran Cloud): recitations, tafsir and
/// translations the bundled mushaf does not carry.
///
/// Ayahs are named by their number in the whole mushaf, 1‥6236 — the same
/// numbering as the bundled text, so the two can be put side by side.
abstract class QuranCloudRepo {
  /// Every edition of [type] the service offers. Kept on the device once
  /// fetched, so the lists still open offline.
  Future<ApiResult<List<QuranEdition>>> getEditions(QuranEditionType type);

  /// Where to fetch [scope] as recited by [reciterId], ayah by ayah.
  Future<ApiResult<List<RecitationAudio>>> getRecitation(
    String reciterId,
    RecitationScope scope,
  );

  /// One ayah's passage in each of [editionIds], in the same order. An
  /// edition the service has no passage for is left out.
  Future<ApiResult<List<EditionText>>> getAyahTexts(
    int ayahId,
    List<String> editionIds,
  );

  /// [limit] ayahs of a surah from [offset] (counting from 0), each with its
  /// passage in every one of [editionIds].
  Future<ApiResult<List<AyahEditionText>>> getSurahTexts(
    int surahNumber,
    List<String> editionIds, {
    required int offset,
    required int limit,
  });

  /// The passages of [editionId] that mention [query], [limit] at a time.
  /// Finding nothing is a success with no matches.
  Future<ApiResult<EditionSearchMatches>> searchEdition(
    String query,
    String editionId, {
    required int offset,
    required int limit,
  });

  /// A passage of [editionId] for an ayah picked at random.
  Future<ApiResult<AyahEditionText>> getRandomAyahText(String editionId);

  /// Where each of the 240 hizb quarters begins, in mushaf order. Fixed
  /// data, kept on the device once fetched.
  Future<ApiResult<List<QuranAyahRef>>> getHizbQuarterStarts();
}
