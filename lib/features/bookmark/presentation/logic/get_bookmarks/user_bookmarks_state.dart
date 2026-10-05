part of 'user_bookmarks_cubit.dart';

@immutable
sealed class GetBookmarksState {}

final class GetBookmarksInitial extends GetBookmarksState {}

final class GetBookmarksLoading extends GetBookmarksState {}

final class UserBookmarksSuccess extends GetBookmarksState {
  final List<UserBookmark> bookmarks;
  final bool isRefreshing;
  final bool isFromCache;

  UserBookmarksSuccess(
    this.bookmarks, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  int get hadithCount => bookmarks.where((b) => b.type == 'hadith').length;

  int get chapterCount => bookmarks.where((b) => b.type == 'chapter').length;

  /// Distinct collections the bookmarks are filed in.
  int get collectionCount =>
      {
        for (final b in bookmarks)
          if ((b.collection ?? '').trim().isNotEmpty) b.collection!.trim(),
      }.length;

  UserBookmarksSuccess copyWith({
    List<UserBookmark>? bookmarks,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return UserBookmarksSuccess(
      bookmarks ?? this.bookmarks,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class GetBookmarksFailure extends GetBookmarksState {
  final String message;
  GetBookmarksFailure(this.message);
}
