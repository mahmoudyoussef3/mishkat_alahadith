part of 'hadith_analysis_cubit.dart';

@immutable
sealed class HadithAnalysisState {}

final class HadithAnalysisInitial extends HadithAnalysisState {}
final class HadithAnalysisLoading extends HadithAnalysisState {}
final class HadithAnalysisLoaded extends HadithAnalysisState {
  final HadithAnalysisResult result;
  HadithAnalysisLoaded(this.result);
}
final class HadithAnalysisError extends HadithAnalysisState {
  final String message;
  HadithAnalysisError(this.message);
}
