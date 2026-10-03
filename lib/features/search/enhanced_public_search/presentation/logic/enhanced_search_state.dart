part of 'enhanced_search_cubit.dart';

@immutable
sealed class EnhancedSearchState {}

final class EnhancedSearchInitial extends EnhancedSearchState {}

final class EnhancedSearchLoading extends EnhancedSearchState {}

final class EnhancedSearchLoaded extends EnhancedSearchState {
  final EnhancedSearch enhancedSearch;
  final bool isRefreshing;
  final bool isFromCache;

  EnhancedSearchLoaded(
    this.enhancedSearch, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  EnhancedSearchLoaded copyWith({
    EnhancedSearch? enhancedSearch,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return EnhancedSearchLoaded(
      enhancedSearch ?? this.enhancedSearch,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class EnhancedSearchError extends EnhancedSearchState {
  final String message;
  EnhancedSearchError(this.message);
}
