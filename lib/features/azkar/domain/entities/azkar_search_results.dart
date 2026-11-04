import 'azkar_category.dart';
import 'zikr.dart';

/// A zikr whose text, or translation, matched the query.
class AzkarSearchHit {
  final AzkarCategory category;
  final Zikr zikr;

  const AzkarSearchHit({required this.category, required this.zikr});
}

class AzkarSearchResults {
  final String query;

  /// Chapters whose title matched, in source order.
  final List<AzkarCategory> categories;
  final List<AzkarSearchHit> hits;

  /// Every matching zikr, including those beyond the returned [hits].
  final int totalHits;

  const AzkarSearchResults({
    required this.query,
    required this.categories,
    required this.hits,
    required this.totalHits,
  });

  bool get isEmpty => categories.isEmpty && hits.isEmpty;

  bool get isTruncated => totalHits > hits.length;
}
