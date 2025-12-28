part of 'get_library_statistics_cubit.dart';

@immutable
sealed class GetLibraryStatisticsState {}

final class GetLibraryStatisticsInitial extends GetLibraryStatisticsState {}

final class GetLivraryStatisticsSuccess extends GetLibraryStatisticsState {
  final StatisticsResponse statisticsResponse;
  GetLivraryStatisticsSuccess({required this.statisticsResponse});
}

final class GetLivraryStatisticsLoading extends GetLibraryStatisticsState {}

final class GetLivraryStatisticsError extends GetLibraryStatisticsState {
  final String errorMessage;
  GetLivraryStatisticsError(this.errorMessage);
}
