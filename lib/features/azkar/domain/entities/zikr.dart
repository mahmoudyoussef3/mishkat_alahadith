/// One remembrance or supplication within a chapter of Hisn Al-Muslim.
class Zikr {
  /// Position within its chapter, from 1.
  final int id;

  /// The Arabic text, fully voweled.
  final String text;

  /// The meaning in the reader's chosen translation, or null when none was
  /// chosen.
  final String? translation;

  /// A Latin-letter rendering of the Arabic, where the source has one.
  final String? transliteration;

  /// How many times it is said; always at least 1.
  final int count;

  /// The recitation's file name («75.mp3»), or null when there is none.
  final String? audioFile;

  const Zikr({
    required this.id,
    required this.text,
    required this.count,
    this.translation,
    this.transliteration,
    this.audioFile,
  });

  bool get isRepeated => count > 1;
}
