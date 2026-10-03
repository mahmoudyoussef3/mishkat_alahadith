part of 'quran_search_cubit.dart';

@immutable
sealed class QuranSearchState {
  const QuranSearchState();
}

/// Nothing typed yet, or too little to search on.
final class QuranSearchIdle extends QuranSearchState {
  const QuranSearchIdle();
}

final class QuranSearchLoading extends QuranSearchState {
  final String query;

  const QuranSearchLoading(this.query);
}

final class QuranSearchSuccess extends QuranSearchState {
  final QuranSearchResults results;

  const QuranSearchSuccess(this.results);
}

final class QuranSearchEmpty extends QuranSearchState {
  final String query;

  const QuranSearchEmpty(this.query);
}

final class QuranSearchFailure extends QuranSearchState {
  final String query;
  final String message;

  const QuranSearchFailure({required this.query, required this.message});
}
