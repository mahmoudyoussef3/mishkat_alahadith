import 'package:mushaf_text/mushaf_text.dart';

/// The mushaf text bundled with `mushaf_text`: fully offline, loaded from the
/// package asset once and cached for the life of the isolate.
///
/// The package also keeps a *failed* load and hands it back to every later
/// call, with no way to reset it. A bundled asset that fails to load is a
/// broken install rather than a passing fault, so retrying would not help
/// anyway; the failure still surfaces as a typed failure through the repo.
class QuranTextLocalDataSource {
  List<Surah> getSurahs() => Quran.surahs;

  Future<List<Ayah>> getAllAyahs() => Quran.ayahs();

  Future<List<Ayah>> getPageAyahs(int page) => Quran.page(page);

  /// Ids run 1‥6236 in mushaf order, so the list index is tried first.
  Future<Ayah?> getAyah(int ayahId) async {
    final ayahs = await Quran.ayahs();
    final index = ayahId - 1;
    if (index >= 0 && index < ayahs.length && ayahs[index].id == ayahId) {
      return ayahs[index];
    }
    return ayahs.where((a) => a.id == ayahId).firstOrNull;
  }

  List<TajweedSpan> annotate(String text, {required bool includeNaturalMadd}) =>
      TajweedAnnotator.annotate(text, includeNaturalMadd: includeNaturalMadd);

  Future<List<MapEntry<TajweedRule, int>>> getPageTajweedCounts(
    int page, {
    required bool includeNaturalMadd,
  }) => pageTajweedCounts(page, includeNaturalMadd: includeNaturalMadd);
}
