part of 'enhanced_search_cubit.dart';

@immutable
sealed class EnhancedSearchState {}

final class EnhancedSearchInitial extends EnhancedSearchState {}

final class EnhancedSearchLoading extends EnhancedSearchState {}

final class EnhancedSearchLoaded extends EnhancedSearchState {
  final List<ExplainedHadith> results;
  final bool isRefreshing;
  final bool isFromCache;

  EnhancedSearchLoaded(
    this.results, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  EnhancedSearchLoaded copyWith({
    List<ExplainedHadith>? results,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return EnhancedSearchLoaded(
      results ?? this.results,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class EnhancedSearchError extends EnhancedSearchState {
  final String message;
  EnhancedSearchError(this.message);
}
