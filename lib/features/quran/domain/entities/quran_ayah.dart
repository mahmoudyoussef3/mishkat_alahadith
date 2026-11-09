class QuranAyah {
  /// The sign the mushaf prints on the fifteen verses of prostration.
  static const String sajdahMark = '۩';

  /// 1‥6236, in mushaf order.
  final int id;
  final int surahNumber;
  final int number;
  final int juz;
  final int page;

  /// The verse in the KFGQPC Uthmanic encoding, without its number.
  final String text;

  const QuranAyah({
    required this.id,
    required this.surahNumber,
    required this.number,
    required this.juz,
    required this.page,
    required this.text,
  });

  bool get isSajdah => text.contains(sajdahMark);

  /// The ayah numbered [id] in [ayahs]: found at once when they are the
  /// whole mushaf in order, as the bundled text is, else by a search.
  static QuranAyah? withId(List<QuranAyah> ayahs, int id) {
    final index = id - 1;
    if (index >= 0 && index < ayahs.length && ayahs[index].id == id) {
      return ayahs[index];
    }
    for (final ayah in ayahs) {
      if (ayah.id == id) return ayah;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is QuranAyah && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
