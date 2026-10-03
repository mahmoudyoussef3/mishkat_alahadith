part of 'search_history_cubit.dart';

@immutable
sealed class SearchHistoryState {}

final class SearchHistoryInitial extends SearchHistoryState {}

final class SearchHistoryLoading extends SearchHistoryState {}

/// عند جلب أو تحديث تاريخ البحث
final class SearchHistorySuccess extends SearchHistoryState {
  final List<SearchHistoryItem> historyItems;
  SearchHistorySuccess(this.historyItems);
}

/// عند وجود خطأ
final class SearchHistoryError extends SearchHistoryState {
  final String errMessage;
  SearchHistoryError(this.errMessage);
}

/// عند جلب إحصائيات البحث
final class SearchHistoryStatsSuccess extends SearchHistoryState {
  final SearchStatsData stats;
  SearchHistoryStatsSuccess(this.stats);
}
