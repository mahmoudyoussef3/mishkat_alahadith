/// A saved place in the mushaf: a whole page, or one ayah on it.
class QuranBookmark {
  final int page;

  /// Null when the bookmark marks the whole page.
  final int? ayahId;
  final int? ayahNumber;
  final int surahNumber;
  final String surahName;
  final DateTime createdAt;

  const QuranBookmark({
    required this.page,
    required this.surahNumber,
    required this.surahName,
    required this.createdAt,
    this.ayahId,
    this.ayahNumber,
  });

  bool get isPageBookmark => ayahId == null;

  /// Whether both point at the same place, whenever they were saved.
  bool sameTargetAs(QuranBookmark other) =>
      isPageBookmark
          ? other.isPageBookmark && other.page == page
          : other.ayahId == ayahId;
}
