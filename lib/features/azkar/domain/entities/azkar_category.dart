import 'zikr.dart';

/// A chapter of Hisn Al-Muslim, such as «أذكار الصباح والمساء».
class AzkarCategory {
  /// The chapter's id in the source, stable across languages.
  final int id;
  final String title;

  /// The title in the reader's chosen translation, or null when none was
  /// chosen.
  final String? translatedTitle;

  /// The recitation of the whole chapter, or null when there is none.
  final String? audioFile;
  final List<Zikr> azkar;

  const AzkarCategory({
    required this.id,
    required this.title,
    required this.azkar,
    this.translatedTitle,
    this.audioFile,
  });

  /// Every repetition the chapter asks for: a zikr said three times counts
  /// three.
  int get totalRepetitions => azkar.fold(0, (sum, zikr) => sum + zikr.count);

  Zikr? zikrById(int zikrId) =>
      azkar.where((zikr) => zikr.id == zikrId).firstOrNull;
}

/// Chapters the app points to by name.
abstract final class AzkarCategoryIds {
  static const int morningEvening = 27;
  static const int sleep = 28;
  static const int waking = 1;
  static const int adhan = 15;
  static const int afterPrayer = 25;
  static const int worry = 34;
  static const int istighfar = 129;
  static const int tasbeeh = 130;
}
