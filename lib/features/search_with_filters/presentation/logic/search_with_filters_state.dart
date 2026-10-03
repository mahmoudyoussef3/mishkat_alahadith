part of 'search_with_filters_cubit.dart';

@immutable
sealed class SearchWithFiltersState {}

final class SearchWithFiltersInitial extends SearchWithFiltersState {}

final class SearchWithFiltersLoading extends SearchWithFiltersState {}

final class SearchWithFiltersSuccess extends SearchWithFiltersState {
  final SearchWithFiltersModel searchWithFiltersModel;
  SearchWithFiltersSuccess(this.searchWithFiltersModel);
}

final class SearchWithFiltersFailure extends SearchWithFiltersState {
  final String errMessage;
  SearchWithFiltersFailure(this.errMessage);
}
