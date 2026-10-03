part of 'get_library_statistics_cubit.dart';

@immutable
sealed class GetLibraryStatisticsState {}

final class GetLibraryStatisticsInitial extends GetLibraryStatisticsState {}

final class GetLivraryStatisticsSuccess extends GetLibraryStatisticsState {
  final LibraryStatistics statistics;
  final bool isRefreshing;
  final bool isFromCache;

  GetLivraryStatisticsSuccess({
    required this.statistics,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  GetLivraryStatisticsSuccess copyWith({
    LibraryStatistics? statistics,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return GetLivraryStatisticsSuccess(
      statistics: statistics ?? this.statistics,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class GetLivraryStatisticsLoading extends GetLibraryStatisticsState {}

final class GetLivraryStatisticsError extends GetLibraryStatisticsState {
  final String errorMessage;
  GetLivraryStatisticsError(this.errorMessage);
}
