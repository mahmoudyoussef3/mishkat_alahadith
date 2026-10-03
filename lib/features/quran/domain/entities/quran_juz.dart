class QuranJuz {
  final int number;
  final int startPage;
  final int startSurahNumber;
  final String startSurahName;
  final int startAyahNumber;

  const QuranJuz({
    required this.number,
    required this.startPage,
    required this.startSurahNumber,
    required this.startSurahName,
    required this.startAyahNumber,
  });

  /// The juz [page] falls in, given the index in mushaf order.
  static QuranJuz? containingPage(List<QuranJuz> juzList, int page) {
    QuranJuz? found;
    for (final juz in juzList) {
      if (juz.startPage > page) break;
      found = juz;
    }
    return found;
  }
}
