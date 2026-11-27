part of 'chapters_cubit.dart';

@immutable
sealed class ChaptersState {}

final class ChaptersInitial extends ChaptersState {}

final class ChaptersLoading extends ChaptersState {}

final class ChaptersSuccess extends ChaptersState {
  final List<BookChapter> allChapters;
  final List<BookChapter> filteredChapters;
  final bool isRefreshing;
  final bool isFromCache;

  /// The chapter to offer under "continue reading", if any.
  final LastReadChapter? lastRead;

  ChaptersSuccess({
    required this.allChapters,
    required this.filteredChapters,
    this.isRefreshing = false,
    this.isFromCache = false,
    this.lastRead,
  });

  ChaptersSuccess copyWith({
    List<BookChapter>? allChapters,
    List<BookChapter>? filteredChapters,
    bool? isRefreshing,
    bool? isFromCache,
    LastReadChapter? lastRead,
  }) {
    return ChaptersSuccess(
      allChapters: allChapters ?? this.allChapters,
      filteredChapters: filteredChapters ?? this.filteredChapters,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
      lastRead: lastRead ?? this.lastRead,
    );
  }
}

final class ChaptersFailure extends ChaptersState {
  final String? errorMessage;
  ChaptersFailure(this.errorMessage);
}
