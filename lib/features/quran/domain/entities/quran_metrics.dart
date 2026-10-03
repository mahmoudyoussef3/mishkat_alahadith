/// Fixed dimensions of the Madinah Mushaf (Hafs ʿan ʿĀṣim).
abstract final class QuranMetrics {
  static const int firstPage = 1;
  static const int pageCount = 604;
  static const int surahCount = 114;
  static const int juzCount = 30;
  static const int ayahCount = 6236;

  static bool isValidPage(int page) => page >= firstPage && page <= pageCount;

  static int clampPage(int page) => page.clamp(firstPage, pageCount);
}
