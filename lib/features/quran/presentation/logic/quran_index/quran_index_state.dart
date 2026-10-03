part of 'quran_index_cubit.dart';

@immutable
sealed class QuranIndexState {
  const QuranIndexState();
}

final class QuranIndexLoading extends QuranIndexState {
  const QuranIndexLoading();
}

final class QuranIndexLoaded extends QuranIndexState {
  final List<QuranSurah> surahs;
  final List<QuranSurah> visibleSurahs;
  final String query;
  final List<QuranJuz> juzList;

  /// Null when the saved bookmarks could not be read.
  final List<QuranBookmark>? bookmarks;
  final QuranLastRead? lastRead;
  final QuranPageInfo? lastReadInfo;

  const QuranIndexLoaded({
    required this.surahs,
    required this.visibleSurahs,
    required this.query,
    required this.juzList,
    required this.bookmarks,
    required this.lastRead,
    required this.lastReadInfo,
  });

  /// The surah to resume — named from the surah table when the page's own
  /// details could not be loaded, and Al-Fātiḥah before any reading.
  QuranSurah? get resumeSurah =>
      lastReadInfo?.openingSurah ??
      QuranSurah.openingAt(surahs, lastRead?.page ?? QuranMetrics.firstPage);

  QuranIndexLoaded copyWith({
    List<QuranSurah>? visibleSurahs,
    String? query,
    List<QuranBookmark>? Function()? bookmarks,
    QuranLastRead? Function()? lastRead,
    QuranPageInfo? Function()? lastReadInfo,
  }) {
    return QuranIndexLoaded(
      surahs: surahs,
      visibleSurahs: visibleSurahs ?? this.visibleSurahs,
      query: query ?? this.query,
      juzList: juzList,
      bookmarks: bookmarks != null ? bookmarks() : this.bookmarks,
      lastRead: lastRead != null ? lastRead() : this.lastRead,
      lastReadInfo: lastReadInfo != null ? lastReadInfo() : this.lastReadInfo,
    );
  }
}

final class QuranIndexFailure extends QuranIndexState {
  final String message;

  const QuranIndexFailure(this.message);
}
