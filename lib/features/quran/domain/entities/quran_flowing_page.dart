import 'quran_ayah.dart';
import 'quran_surah.dart';
import 'tajweed_info.dart';

/// A mushaf page as running text, for the flowing layout: the same ayahs as
/// the printed page, grouped by the surah they belong to.
class QuranFlowingPage {
  final int page;

  /// In reading order; more than one when a surah begins on the page.
  final List<QuranFlowingSection> sections;

  const QuranFlowingPage({required this.page, required this.sections});
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
}
