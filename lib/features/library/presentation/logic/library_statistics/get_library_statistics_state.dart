part of 'get_library_statistics_cubit.dart';

@immutable
sealed class GetLibraryStatisticsState {}

final class GetLibraryStatisticsInitial extends GetLibraryStatisticsState {}

final class GetLivraryStatisticsSuccess extends GetLibraryStatisticsState {
  final StatisticsResponse statisticsResponse;
  final bool isRefreshing;
  final bool isFromCache;

  GetLivraryStatisticsSuccess({
    required this.statisticsResponse,
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  GetLivraryStatisticsSuccess copyWith({
    StatisticsResponse? statisticsResponse,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return GetLivraryStatisticsSuccess(
      statisticsResponse: statisticsResponse ?? this.statisticsResponse,
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
