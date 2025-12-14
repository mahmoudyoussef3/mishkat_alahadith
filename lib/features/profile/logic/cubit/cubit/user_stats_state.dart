part of 'user_stats_cubit.dart';

@immutable
sealed class UserStatsState {}

final class UserStatsInitial extends UserStatsState {}
final class UserStatsLoaded extends UserStatsState  {
  final StatsModel stats;
  UserStatsLoaded(this.stats);
}
final class UserStatsError extends UserStatsState {
  final String message;
  UserStatsError(this.message);
}
final class UserStatsLoading extends UserStatsState {}

