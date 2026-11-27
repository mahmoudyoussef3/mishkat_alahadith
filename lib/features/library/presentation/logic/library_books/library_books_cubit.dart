import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_book.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_books_use_case.dart';

part 'library_books_state.dart';

/// The library shelf for the selected categories: cached books first, then
/// the server's.
class LibraryBooksCubit extends Cubit<LibraryBooksState> {
  final GetLibraryBooksUseCase _getLibraryBooks;

  LibraryBooksCubit(this._getLibraryBooks) : super(LibraryBooksInitial());

  /// Identifies the latest [load], so a slower response for a filter the
  /// user already left never replaces the current shelf.
  int _generation = 0;

  Future<void> load(List<String> categoryIds) async {
    final generation = ++_generation;

    final cached = await _getLibraryBooks.cached(categoryIds);
    if (_isStale(generation)) return;
    emit(
      cached == null
          ? LibraryBooksLoading()
          : LibraryBooksLoaded(cached, isRefreshing: true),
    );

    final result = await _getLibraryBooks(categoryIds);
    if (_isStale(generation)) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(LibraryBooksLoaded(data));
      case ApiFailure(:final failure):
        // Keep showing the cached shelf rather than an error.
        emit(
          cached == null
              ? LibraryBooksError(failure.message)
              : LibraryBooksLoaded(cached),
        );
    }
  }

  bool _isStale(int generation) => isClosed || generation != _generation;
}
