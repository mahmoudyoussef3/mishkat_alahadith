part of 'daily_zekr_cubit.dart';

@immutable
sealed class DailyZekrState {}

final class DailyZekrInitial extends DailyZekrState {}

final class DailyZekrLoading extends DailyZekrState {}

final class DailyZekrLoaded extends DailyZekrState {
  final List<ZekrItem> items;
  DailyZekrLoaded(this.items);
}

final class DailyZekrError extends DailyZekrState {
  final String message;
  DailyZekrError(this.message);
}
