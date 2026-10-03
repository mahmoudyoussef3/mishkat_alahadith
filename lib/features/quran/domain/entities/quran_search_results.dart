import 'quran_ayah.dart';

/// Where the query matched, in the ayah's original (diacritised) text.
class QuranTextMatch {
  final int start;
  final int end;

  const QuranTextMatch({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      other is QuranTextMatch && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'QuranTextMatch($start, $end)';
}

class QuranSearchHit {
  final QuranAyah ayah;
  final String surahName;
  final List<QuranTextMatch> matches;

  const QuranSearchHit({
    required this.ayah,
    required this.surahName,
    required this.matches,
  });
}

class QuranSearchResults {
  final String query;
  final List<QuranSearchHit> hits;

  /// Every matching ayah, including those beyond the returned [hits].
  final int totalMatches;

  const QuranSearchResults({
    required this.query,
    required this.hits,
    required this.totalMatches,
  });

  bool get isEmpty => hits.isEmpty;

  bool get isTruncated => totalMatches > hits.length;
}
