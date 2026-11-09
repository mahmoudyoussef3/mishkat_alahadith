import 'quran_ayah.dart';
import 'quran_edition.dart';
import 'quran_search_results.dart';

/// A page of matches as the service returns them.
class EditionSearchMatches {
  final List<AyahEditionMatch> matches;

  /// Every match, including those on later pages.
  final int total;

  const EditionSearchMatches({required this.matches, required this.total});

  static const EditionSearchMatches empty = EditionSearchMatches(
    matches: [],
    total: 0,
  );
}

/// One passage of an edition the query was found in.
class AyahEditionMatch {
  final int ayahId;
  final String text;
  final QuranEdition? edition;

  const AyahEditionMatch({
    required this.ayahId,
    required this.text,
    this.edition,
  });
}

/// An ayah whose tafsir or translation mentions the query.
class EditionSearchHit {
  final QuranAyah ayah;
  final String surahName;

  /// The part of the passage around the first match, ellipsised where cut.
  final String excerpt;

  /// Where the query falls in [excerpt].
  final List<QuranTextMatch> matches;

  const EditionSearchHit({
    required this.ayah,
    required this.surahName,
    required this.excerpt,
    required this.matches,
  });
}

/// One page of results for a search in a tafsir or translation.
class EditionSearchPage {
  final String query;
  final String editionId;
  final List<EditionSearchHit> hits;

  /// Every match, across all pages.
  final int total;

  /// Where [hits] start among all the matches, from 0.
  final int offset;

  /// How many matches the service returned for this page, before any that
  /// could not be placed in the mushaf were dropped.
  final int fetched;

  const EditionSearchPage({
    required this.query,
    required this.editionId,
    required this.hits,
    required this.total,
    required this.offset,
    required this.fetched,
  });

  int get nextOffset => offset + fetched;

  bool get hasMore => fetched > 0 && nextOffset < total;
}
