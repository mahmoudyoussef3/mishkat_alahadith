/// What an edition of the online Quran service holds.
enum QuranEditionType {
  /// Verse-by-verse audio by one reciter.
  recitation,

  /// A commentary, one passage per ayah.
  tafsir,

  /// A translation of the meanings, one passage per ayah.
  translation,
}

/// One edition of the online Quran service: a reciter, a tafsir or a
/// translation, named by its stable [identifier] such as `ar.alafasy`.
class QuranEdition {
  final String identifier;

  /// In the edition's own language — «مشاري العفاسي», «تفسير الجلالين».
  final String name;
  final String englishName;

  /// ISO 639-1 code: `ar`, `en`, `ur`…
  final String language;
  final QuranEditionType type;

  /// Whether its text runs right to left. Meaningless for recitations.
  final bool isRightToLeft;

  const QuranEdition({
    required this.identifier,
    required this.name,
    required this.englishName,
    required this.language,
    required this.type,
    required this.isRightToLeft,
  });

  bool get isArabic => language == 'ar';

  @override
  bool operator ==(Object other) =>
      other is QuranEdition && other.identifier == identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'QuranEdition($identifier)';
}

/// The editions picked when the reader has not chosen any, so every screen
/// works — and can name what it plays — before the edition lists load.
abstract final class DefaultQuranEditions {
  static const QuranEdition reciter = QuranEdition(
    identifier: 'ar.alafasy',
    name: 'مشاري العفاسي',
    englishName: 'Alafasy',
    language: 'ar',
    type: QuranEditionType.recitation,
    isRightToLeft: true,
  );

  static const QuranEdition tafsir = QuranEdition(
    identifier: 'ar.muyassar',
    name: 'التفسير الميسر',
    englishName: 'King Fahad Quran Complex',
    language: 'ar',
    type: QuranEditionType.tafsir,
    isRightToLeft: true,
  );
}
