part of 'daily_hadith_cubit.dart';

@immutable
sealed class DailyHadithState {}

final class DailyHadithInitial extends DailyHadithState {}

final class DailyHadithLoading extends DailyHadithState {}

final class DailyHadithSuccess extends DailyHadithState {
  final NewDailyHadithModel dailyHadithModel;
  DailyHadithSuccess(this.dailyHadithModel);
}

final class DailyHadithFailure extends DailyHadithState {
  final String errMessage;
  DailyHadithFailure(this.errMessage);
}
