import 'package:mishkat_almasabih/core/helpers/arabic_text_fold.dart';

import '../entities/azkar_category.dart';
import '../entities/azkar_search_results.dart';
import '../entities/zikr.dart';

/// Searches chapter titles and the azkar themselves, in the Arabic and in the
/// translation being shown, regardless of harakat, letter variants or case:
/// «سبحان الله» finds «سُبْحَانَ اللَّهِ», and «glory» finds «Glory».
///
/// The folded text is built once per catalogue and kept, so every keystroke
/// after the first is a plain scan.
class SearchAzkarUseCase {
  static const int minQueryLength = 2;
  static const int maxHits = 60;

  /// Joins the fields of one entry so a query cannot match across two.
  static const String _fieldBreak = '\u0001';

  List<AzkarCategory>? _indexedCatalog;
  List<_IndexedCategory> _index = const [];

  bool canSearch(String query) => fold(query).length >= minQueryLength;

  AzkarSearchResults call(List<AzkarCategory> catalog, String query) {
    final needle = fold(query);
    if (needle.length < minQueryLength) {
      return AzkarSearchResults(
        query: query,
        categories: const [],
        hits: const [],
        totalHits: 0,
      );
    }

    final categories = <AzkarCategory>[];
    final hits = <AzkarSearchHit>[];
    var totalHits = 0;
    for (final entry in _indexFor(catalog)) {
      if (entry.title.contains(needle)) categories.add(entry.category);
      for (final zikr in entry.azkar) {
        if (!zikr.text.contains(needle)) continue;
        totalHits++;
        if (hits.length < maxHits) {
          hits.add(AzkarSearchHit(category: entry.category, zikr: zikr.zikr));
        }
      }
    }
    return AzkarSearchResults(
      query: query,
      categories: categories,
      hits: hits,
      totalHits: totalHits,
    );
  }

  /// Arabic folded to its everyday spelling, Latin to lower case.
  static String fold(String input) =>
      ArabicTextFold.foldSpelling(input).toLowerCase();

  List<_IndexedCategory> _indexFor(List<AzkarCategory> catalog) {
    if (identical(catalog, _indexedCatalog)) return _index;
    _index = [
      for (final category in catalog)
        _IndexedCategory(
          category: category,
          title: _foldFields([category.title, category.translatedTitle]),
          azkar: [
            for (final zikr in category.azkar)
              _IndexedZikr(
                zikr: zikr,
                text: _foldFields([
                  zikr.text,
                  zikr.translation,
                  zikr.transliteration,
                ]),
              ),
          ],
        ),
    ];
    _indexedCatalog = catalog;
    return _index;
  }

  static String _foldFields(List<String?> fields) => [
    for (final field in fields)
      if (field != null && field.isNotEmpty) fold(field),
  ].join(_fieldBreak);
}

class _IndexedCategory {
  final AzkarCategory category;
  final String title;
  final List<_IndexedZikr> azkar;

  const _IndexedCategory({
    required this.category,
    required this.title,
    required this.azkar,
  });
}

class _IndexedZikr {
  final Zikr zikr;
  final String text;

  const _IndexedZikr({required this.zikr, required this.text});
}
