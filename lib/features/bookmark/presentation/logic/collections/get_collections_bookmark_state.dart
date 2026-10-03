part of 'get_collections_bookmark_cubit.dart';

@immutable
sealed class GetCollectionsBookmarkState {}

final class GetCollectionsBookmarkInitial extends GetCollectionsBookmarkState {}

final class GetCollectionsBookmarkLoading extends GetCollectionsBookmarkState {}

final class GetCollectionsBookmarkSuccess extends GetCollectionsBookmarkState {
  final List<BookmarkCollection> collections;
  final bool isRefreshing;
  final bool isFromCache;

  GetCollectionsBookmarkSuccess(
    this.collections, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  GetCollectionsBookmarkSuccess copyWith({
    List<BookmarkCollection>? collections,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return GetCollectionsBookmarkSuccess(
      collections ?? this.collections,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class GetCollectionsBookmarkError extends GetCollectionsBookmarkState {
  final String errMessage;
  GetCollectionsBookmarkError(this.errMessage);
}
