import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_ayah.dart';
import '../entities/quran_search_results.dart';
import '../repos/quran_repo.dart';
import '../services/quran_text_normalizer.dart';

/// Full-text search over every ayah, tolerant of harakat and spelling.
///
/// The folded text of all 6236 ayahs is built once and kept, so every query
/// after the first is a plain scan. Highlight ranges are only worked out for
/// the hits actually returned.
class SearchQuranUseCase {
  static const int minQueryLength = 2;
  static const int maxHits = 200;

  final QuranRepo _repo;

  List<_IndexedAyah>? _index;
  Future<ApiResult<List<_IndexedAyah>>>? _indexBuild;
  Map<int, String> _surahNames = const {};

  SearchQuranUseCase(this._repo);

  bool canSearch(String query) =>
      QuranTextNormalizer.normalize(query).length >= minQueryLength;

  Future<ApiResult<QuranSearchResults>> call(String query) async {
    final needle = QuranTextNormalizer.normalize(query);
    if (needle.length < minQueryLength) {
      return ApiResult.success(
        QuranSearchResults(query: query, hits: const [], totalMatches: 0),
      );
    }

    final indexResult = await _loadIndex();
    switch (indexResult) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: final index):
        final hits = <QuranSearchHit>[];
        var total = 0;
        for (final entry in index) {
          if (!entry.folded.contains(needle)) continue;
          total++;
          if (hits.length < maxHits) hits.add(_hit(entry.ayah, needle));
        }
        return ApiResult.success(
          QuranSearchResults(query: query, hits: hits, totalMatches: total),
        );
    }
  }

  QuranSearchHit _hit(QuranAyah ayah, String needle) {
    final normalized = QuranTextNormalizer.normalizeWithMap(ayah.text);
    final matches = <QuranTextMatch>[];
    var from = normalized.value.indexOf(needle);
    while (from >= 0) {
      final range = normalized.sourceRange(from, from + needle.length);
      matches.add(QuranTextMatch(start: range.start, end: range.end));
      from = normalized.value.indexOf(needle, from + needle.length);
    }
    return QuranSearchHit(
      ayah: ayah,
      surahName: _surahNames[ayah.surahNumber] ?? '',
      matches: matches,
    );
  }

  /// Shares one build between queries typed while it is still running, and
  /// forgets a failed build so the next query can try again.
  Future<ApiResult<List<_IndexedAyah>>> _loadIndex() {
    final cached = _index;
    if (cached != null) return Future.value(ApiResult.success(cached));
    return _indexBuild ??= _buildIndex().then((result) {
      _indexBuild = null;
      return result;
    });
  }

  Future<ApiResult<List<_IndexedAyah>>> _buildIndex() async {
    final ayahsResult = await _repo.getAllAyahs();
    final surahsResult = await _repo.getSurahs();
    switch ((ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (ApiSuccess(data: final ayahs), ApiSuccess(data: final surahs)):
        _surahNames = {for (final s in surahs) s.number: s.nameArabic};
        final index = [
          for (final ayah in ayahs)
            _IndexedAyah(ayah, QuranTextNormalizer.normalize(ayah.text)),
        ];
        _index = index;
        return ApiResult.success(index);
    }
  }
}

class _IndexedAyah {
  final QuranAyah ayah;
  final String folded;

  const _IndexedAyah(this.ayah, this.folded);
}
