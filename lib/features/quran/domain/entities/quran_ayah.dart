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

  @override
  bool operator ==(Object other) => other is QuranAyah && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
