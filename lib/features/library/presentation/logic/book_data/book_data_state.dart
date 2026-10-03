part of 'book_data_cubit.dart';

@immutable
sealed class BookDataState {}

final class BookDataInitial extends BookDataState {}

final class BookDataLoading extends BookDataState {}

final class BookDataSuccess extends BookDataState {
  final CategoryBooks categoryBooks;
  final bool isRefreshing;
  final bool isFromCache;

  BookDataSuccess(
    this.categoryBooks, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  BookDataSuccess copyWith({
    CategoryBooks? categoryBooks,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return BookDataSuccess(
      categoryBooks ?? this.categoryBooks,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class BookDataFailure extends BookDataState {
  final String errorMessage;
  BookDataFailure(this.errorMessage);
}
