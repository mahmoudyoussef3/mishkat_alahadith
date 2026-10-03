class QuranSurah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int ayahCount;
  final int startPage;
  final int endPage;

  const QuranSurah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.ayahCount,
    required this.startPage,
    required this.endPage,
  });

  int get pageCount => endPage - startPage + 1;

  bool containsPage(int page) => page >= startPage && page <= endPage;

  /// The surah a page opens with — the one its header names in print.
  ///
  /// A page shared by two surahs belongs to the one that is still running at
  /// its top, so page 106 is An-Nisāʾ even though Al-Māʾidah starts on it.
  static QuranSurah? openingAt(List<QuranSurah> surahs, int page) {
    for (final surah in surahs) {
      if (surah.containsPage(page)) return surah;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is QuranSurah && other.number == number;

  @override
  int get hashCode => number.hashCode;
}
