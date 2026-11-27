/// Where an ayah sits by surah and number within it.
typedef QuranAyahRef = ({int surah, int ayah});

/// One of the 240 quarters of the sixty ahzāb.
class QuranHizbQuarter {
  /// 1‥240, in mushaf order.
  final int number;
  final int startAyahId;
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final int page;

  const QuranHizbQuarter({
    required this.number,
    required this.startAyahId,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.page,
  });

  /// 1‥60.
  int get hizb => hizbOf(number);

  /// 0 for the hizb's start, then 1, 2 and 3 for its quarter, half and
  /// three quarters.
  int get quarter => quarterOf(number);

  /// Two ahzāb to a juz.
  int get juz => (number - 1) ~/ 8 + 1;

  /// The hizb (1‥60) that quarter [number] (1‥240) belongs to.
  static int hizbOf(int number) => (number - 1) ~/ 4 + 1;

  /// How far into its hizb quarter [number] (1‥240) falls, 0‥3.
  static int quarterOf(int number) => (number - 1) % 4;

  /// The quarter [ayahId] is in, given the quarters in mushaf order.
  static QuranHizbQuarter? containingAyah(
    List<QuranHizbQuarter> quarters,
    int ayahId,
  ) {
    QuranHizbQuarter? found;
    for (final quarter in quarters) {
      if (quarter.startAyahId > ayahId) break;
      found = quarter;
    }
    return found;
  }

  @override
  bool operator ==(Object other) =>
      other is QuranHizbQuarter && other.number == number;

  @override
  int get hashCode => number.hashCode;
}
