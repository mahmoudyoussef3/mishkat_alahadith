part of 'mushaf_reader_cubit.dart';

enum BookmarkToggleResult { added, removed, failed }

@immutable
sealed class MushafReaderState {
  const MushafReaderState();
}

final class MushafReaderLoading extends MushafReaderState {
  const MushafReaderLoading();
}

final class MushafReaderReady extends MushafReaderState {
  final int page;
  final MushafReaderSettings settings;
  final List<QuranSurah> surahs;
  final List<QuranBookmark> bookmarks;

  /// The surah being read, which the page slider spans: the one opened, kept
  /// while its pages are turned, then the surah the reader turns into. Null
  /// only when no surah covers the page.
  final QuranSurah? readingSurah;

  /// Null until the current page's details have loaded.
  final QuranPageInfo? pageInfo;

  /// How many words on the current page carry each rule, most frequent first.
  /// Empty while tajweed is off.
  final List<TajweedRuleCount> ruleCounts;

  /// The page's rules could not be counted; see `retryRuleCounts`.
  final bool ruleCountsFailed;

  /// The rule whose occurrences the reader is stepping through, if any.
  final String? focusRuleKey;
  final int focusIndex;

  /// The ayah washed with the highlight colour.
  final int? selectedAyahId;

  const MushafReaderReady({
    required this.page,
    required this.settings,
    required this.surahs,
    required this.bookmarks,
    this.readingSurah,
    this.pageInfo,
    this.ruleCounts = const [],
    this.ruleCountsFailed = false,
    this.focusRuleKey,
    this.focusIndex = 0,
    this.selectedAyahId,
  });

  /// The surah the header names: the one being read, or else the one the
  /// page opens with, available even before [pageInfo] loads.
  QuranSurah? get headerSurah =>
      readingSurah ??
      pageInfo?.openingSurah ??
      QuranSurah.openingAt(surahs, page);

  /// The pages of [readingSurah], which the page slider scrubs, or the whole
  /// mushaf when no surah covers the page.
  ({int first, int last}) get surahPages {
    final surah = readingSurah;
    return surah == null
        ? (first: QuranMetrics.firstPage, last: QuranMetrics.pageCount)
        : (first: surah.startPage, last: surah.endPage);
  }

  bool get isPageBookmarked =>
      bookmarks.any((b) => b.isPageBookmark && b.page == page);

  bool isAyahBookmarked(int ayahId) => bookmarks.any((b) => b.ayahId == ayahId);

  int get focusTotal {
    final key = focusRuleKey;
    if (key == null) return 0;
    for (final count in ruleCounts) {
      if (count.ruleKey == key) return count.count;
    }
    return 0;
  }

  bool get isFocusing => focusTotal > 0;

  MushafReaderReady copyWith({
    int? page,
    MushafReaderSettings? settings,
    List<QuranBookmark>? bookmarks,
    QuranSurah? Function()? readingSurah,
    QuranPageInfo? Function()? pageInfo,
    List<TajweedRuleCount>? ruleCounts,
    bool? ruleCountsFailed,
    String? Function()? focusRuleKey,
    int? focusIndex,
    int? Function()? selectedAyahId,
  }) {
    return MushafReaderReady(
      page: page ?? this.page,
      settings: settings ?? this.settings,
      surahs: surahs,
      bookmarks: bookmarks ?? this.bookmarks,
      readingSurah: readingSurah != null ? readingSurah() : this.readingSurah,
      pageInfo: pageInfo != null ? pageInfo() : this.pageInfo,
      ruleCounts: ruleCounts ?? this.ruleCounts,
      ruleCountsFailed: ruleCountsFailed ?? this.ruleCountsFailed,
      focusRuleKey: focusRuleKey != null ? focusRuleKey() : this.focusRuleKey,
      focusIndex: focusIndex ?? this.focusIndex,
      selectedAyahId:
          selectedAyahId != null ? selectedAyahId() : this.selectedAyahId,
    );
  }
}

final class MushafReaderFailure extends MushafReaderState {
  final String message;

  const MushafReaderFailure(this.message);
}
