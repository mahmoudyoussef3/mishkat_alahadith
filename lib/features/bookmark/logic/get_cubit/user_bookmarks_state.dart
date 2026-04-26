part of 'user_bookmarks_cubit.dart';

@immutable
sealed class GetBookmarksState {}

final class GetBookmarksInitial extends GetBookmarksState {}

final class GetBookmarksLoading extends GetBookmarksState {}

final class UserBookmarksSuccess extends GetBookmarksState {
  final List<Bookmark> bookmarks;
  final bool isRefreshing;
  final bool isFromCache;

  UserBookmarksSuccess(
    this.bookmarks, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  UserBookmarksSuccess copyWith({
    List<Bookmark>? bookmarks,
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
