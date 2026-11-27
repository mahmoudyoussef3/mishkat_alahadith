import 'quran_ayah.dart';
import 'quran_surah.dart';
import 'tajweed_info.dart';

/// A word of a page: which ayah, and where it starts in that ayah's text.
typedef FlowingWordRef = ({int ayahId, int charStart});

/// A mushaf page as running text, for the flowing layout: the same ayahs as
/// the printed page, grouped by the surah they belong to.
class QuranFlowingPage {
  final int page;

  /// In reading order; more than one when a surah begins on the page.
  final List<QuranFlowingSection> sections;

  const QuranFlowingPage({required this.page, required this.sections});

  /// The word the tajweed focus is on: the [index]th word of the page that
  /// carries [ruleKey], in reading order, wrapping.
  ///
  /// The printed page counts the same stops — a word carrying the rule twice
  /// is still one — so the focus bar's «ن من م» holds in both layouts.
  FlowingWordRef? focusStop(String ruleKey, int index) {
    final stops = <FlowingWordRef>[];
    for (final section in sections) {
      for (final flowing in section.ayahs) {
        final segments = [
          for (final s in flowing.tajweed)
            if (s.ruleKey == ruleKey) s,
        ];
        if (segments.isEmpty) continue;
        for (final word in flowing.words) {
          if (segments.any((s) => s.start < word.end && s.end > word.start)) {
            stops.add((ayahId: flowing.ayah.id, charStart: word.start));
          }
        }
      }
    }
    if (stops.isEmpty) return null;
    return stops[index % stops.length];
  }
}

/// The ayahs of one surah on a page.
class QuranFlowingSection {
  final QuranSurah surah;

  /// The surah's first ayah is on this page, so its title is shown above it.
  final bool opensHere;

  final List<QuranFlowingAyah> ayahs;

  const QuranFlowingSection({
    required this.surah,
    required this.opensHere,
    required this.ayahs,
  });

  /// The basmala goes between the title and the first ayah.
  bool get showsBasmala => opensHere && surah.printsBasmala;
}

/// An ayah with its tajweed, as the reader's settings ask for it.
class QuranFlowingAyah {
  final QuranAyah ayah;
  final List<TajweedSegment> tajweed;

  const QuranFlowingAyah({required this.ayah, required this.tajweed});

  /// `[start, end)` of each word of the ayah: the runs between spaces, split
  /// the way the printed page splits them, so its marks stay on their letters.
  List<({int start, int end})> get words {
    final text = ayah.text;
    final words = <({int start, int end})>[];
    var at = 0;
    while (at < text.length) {
      if (text[at] == ' ') {
        at++;
        continue;
      }
      var end = at;
      while (end < text.length && text[end] != ' ') {
        end++;
      }
      words.add((start: at, end: end));
      at = end;
    }
    return words;
  }
}
