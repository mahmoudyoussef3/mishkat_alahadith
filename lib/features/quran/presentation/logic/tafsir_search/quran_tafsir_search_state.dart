part of 'quran_tafsir_search_cubit.dart';

@immutable
sealed class QuranTafsirSearchState {
  /// The tafsir searched.
  final String tafsirId;

  const QuranTafsirSearchState(this.tafsirId);
}

/// Nothing typed yet, or too little to search on.
final class QuranTafsirSearchIdle extends QuranTafsirSearchState {
  const QuranTafsirSearchIdle(super.tafsirId);
}

final class QuranTafsirSearchLoading extends QuranTafsirSearchState {
  final String query;

  const QuranTafsirSearchLoading(super.tafsirId, {required this.query});
}

final class QuranTafsirSearchSuccess extends QuranTafsirSearchState {
  final String query;
  final List<EditionSearchHit> hits;

  /// Every match, across all pages.
  final int total;
  final int nextOffset;
  final bool hasMore;
  final bool isLoadingMore;

  /// Why the last page could not be loaded; null when it could.
  final String? loadMoreFailure;

  const QuranTafsirSearchSuccess(
    super.tafsirId, {
    required this.query,
    required this.hits,
    required this.total,
    required this.nextOffset,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  QuranTafsirSearchSuccess copyWith({
    List<EditionSearchHit>? hits,
    int? nextOffset,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? loadMoreFailure,
  }) {
    return QuranTafsirSearchSuccess(
      tafsirId,
      query: query,
      hits: hits ?? this.hits,
      total: total,
      nextOffset: nextOffset ?? this.nextOffset,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure:
          loadMoreFailure != null ? loadMoreFailure() : this.loadMoreFailure,
    );
  }
}

final class QuranTafsirSearchEmpty extends QuranTafsirSearchState {
  final String query;

  const QuranTafsirSearchEmpty(super.tafsirId, {required this.query});
}

final class QuranTafsirSearchFailure extends QuranTafsirSearchState {
  final String query;
  final String message;

  const QuranTafsirSearchFailure(
    super.tafsirId, {
    required this.query,
    required this.message,
  });
}
