part of 'hadith_by_category_details_cubit.dart';

@immutable
sealed class HadithByCategoryDetailsState {}

final class HadithByCategoryDetailsInitial extends HadithByCategoryDetailsState {}
final class HadithByCategoryDetailsLoading extends HadithByCategoryDetailsState {}  
final class HadithByCategoryDetailsLoaded extends HadithByCategoryDetailsState {
  final NewDailyHadithModel dailyHadithModel;
  HadithByCategoryDetailsLoaded(this.dailyHadithModel);
}
final class HadithByCategoryDetailsError extends HadithByCategoryDetailsState {
  final String message;

  HadithByCategoryDetailsError(this.message);
}
