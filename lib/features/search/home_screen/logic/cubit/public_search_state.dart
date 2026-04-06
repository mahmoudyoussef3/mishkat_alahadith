part of 'public_search_cubit.dart';

@immutable
sealed class PublicSearchState {}

final class PublicSearchInitial extends PublicSearchState {}

final class PublicSearchLoading extends PublicSearchState {}

final class PublicSearchSuccess extends PublicSearchState {
  final SearchResponse searchResponse;
  final bool isRefreshing;
  final bool isFromCache;

  PublicSearchSuccess(
    this.searchResponse, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  PublicSearchSuccess copyWith({
    SearchResponse? searchResponse,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return PublicSearchSuccess(
      searchResponse ?? this.searchResponse,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class PublicSearchFailure extends PublicSearchState {
  final String message;
  PublicSearchFailure(this.message);
}
