import '../entities/quran_search_results.dart';
import 'quran_text_normalizer.dart';

/// A short part of a long passage, and where the query falls in it.
typedef TextExcerpt = ({String text, List<QuranTextMatch> matches});

/// Cuts tafsir and translation passages — some run to pages — down to the
/// words around a search match, the way a search engine shows a snippet.
abstract final class TextExcerpts {
  static const String ellipsis = '…';

  /// The words around the first place [query] occurs in [text], at most
  /// about [radius] characters either side, with every occurrence inside
  /// marked. Arabic is compared without harakat or spelling variants, as in
  /// the mushaf search; other scripts without letter case.
  ///
  /// When the query cannot be found — the service matches in its own way —
  /// the passage's opening is returned, with nothing marked.
  static TextExcerpt around(String text, String query, {int radius = 90}) {
    final source = text.trim();
    final occurrences = _find(source, query.trim());
    if (occurrences.isEmpty) {
      return (text: _cut(source, 0, radius * 2).text, matches: const []);
    }

    final first = occurrences.first;
    final cut = _cut(source, first.start - radius, first.end + radius);
    return (
      text: cut.text,
      matches: [
        for (final match in occurrences)
          if (match.start >= cut.from && match.end <= cut.to)
            QuranTextMatch(
              start: match.start - cut.from + cut.shift,
              end: match.end - cut.from + cut.shift,
            ),
      ],
    );
  }

  /// [source] from [from] to [to], widened to whole words and ellipsised at
  /// either end that was cut. [shift] is how far the kept text moved right
  /// for the leading ellipsis.
  static ({String text, int from, int to, int shift}) _cut(
    String source,
    int from,
    int to,
  ) {
    var start = from.clamp(0, source.length);
    var end = to.clamp(start, source.length);
    // Back to the start of the word the cut falls in, and on to its end.
    while (start > 0 && !_isBreak(source.codeUnitAt(start - 1))) {
      start--;
    }
    while (end < source.length && !_isBreak(source.codeUnitAt(end))) {
      end++;
    }
    final lead = start > 0 ? '$ellipsis ' : '';
    final tail = end < source.length ? ' $ellipsis' : '';
    return (
      text: '$lead${source.substring(start, end)}$tail',
      from: start,
      to: end,
      shift: lead.length,
    );
  }

  static bool _isBreak(int unit) => unit == 0x20 || unit == 0x0A;

  static List<({int start, int end})> _find(String text, String query) {
    if (query.isEmpty) return const [];
    return _hasArabic(query)
        ? _findArabic(text, query)
        : _findLatin(text, query);
  }

  static List<({int start, int end})> _findArabic(String text, String query) {
    final needle = QuranTextNormalizer.normalize(query);
    if (needle.isEmpty) return const [];
    final folded = QuranTextNormalizer.normalizeWithMap(text);
    final found = <({int start, int end})>[];
    var at = folded.value.indexOf(needle);
    while (at >= 0) {
      found.add(folded.sourceRange(at, at + needle.length));
      at = folded.value.indexOf(needle, at + needle.length);
    }
    return found;
  }

  static List<({int start, int end})> _findLatin(String text, String query) {
    final haystack = text.toLowerCase();
    final needle = query.toLowerCase();
    // Lower-casing keeps every UTF-16 length the same for the scripts the
    // translations use, so indices into [haystack] are indices into [text].
    if (haystack.length != text.length) return const [];
    final found = <({int start, int end})>[];
    var at = haystack.indexOf(needle);
    while (at >= 0) {
      found.add((start: at, end: at + needle.length));
      at = haystack.indexOf(needle, at + needle.length);
    }
    return found;
  }

  static bool _hasArabic(String text) =>
      text.codeUnits.any((unit) => unit >= 0x0600 && unit <= 0x06FF);
}
