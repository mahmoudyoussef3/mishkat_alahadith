part of 'library_books_cubit.dart';

@immutable
sealed class LibraryBooksState {}

final class LibraryBooksInitial extends LibraryBooksState {}

final class LibraryBooksLoading extends LibraryBooksState {}

final class LibraryBooksLoaded extends LibraryBooksState {
  final List<LibraryBook> books;

  /// True while showing cached books and waiting for the server's.
  final bool isRefreshing;

  LibraryBooksLoaded(this.books, {this.isRefreshing = false});
}

final class LibraryBooksError extends LibraryBooksState {
  final String message;

  LibraryBooksError(this.message);
}
