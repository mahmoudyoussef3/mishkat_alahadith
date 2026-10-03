part of 'search_history_cubit.dart';

@immutable
sealed class SearchHistoryState {}

final class SearchHistoryInitial extends SearchHistoryState {}

final class SearchHistoryLoading extends SearchHistoryState {}

final class SearchHistorySuccess extends SearchHistoryState {
  final List<SearchHistoryEntry> historyItems;
  SearchHistorySuccess(this.historyItems);
}

final class SearchHistoryError extends SearchHistoryState {
  final String errMessage;
  SearchHistoryError(this.errMessage);
}
