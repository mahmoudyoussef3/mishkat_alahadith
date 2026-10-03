part of 'book_data_cubit.dart';

@immutable
sealed class BookDataState {}

final class BookDataInitial extends BookDataState {}

final class BookDataLoading extends BookDataState {}

final class BookDataSuccess extends BookDataState {
  final CategoryResponse categoryResponse;
  final bool isRefreshing;
  final bool isFromCache;

  BookDataSuccess(
    this.categoryResponse, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  BookDataSuccess copyWith({
    CategoryResponse? categoryResponse,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return BookDataSuccess(
      categoryResponse ?? this.categoryResponse,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class BookDataFailure extends BookDataState {
  final String errorMessage;
  BookDataFailure(this.errorMessage);
}
