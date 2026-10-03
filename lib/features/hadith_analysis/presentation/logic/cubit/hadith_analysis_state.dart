part of 'hadith_analysis_cubit.dart';

@immutable
sealed class HadithAnalysisState {}

final class HadithAnalysisInitial extends HadithAnalysisState {}
final class HadithAnalysisLoading extends HadithAnalysisState {}
final class HadithAnalysisLoaded extends HadithAnalysisState {
  final HadithAnalysisResponse response;
  HadithAnalysisLoaded(this.response);
}
final class HadithAnalysisError extends HadithAnalysisState {
  final String message;
  HadithAnalysisError(this.message);
}
