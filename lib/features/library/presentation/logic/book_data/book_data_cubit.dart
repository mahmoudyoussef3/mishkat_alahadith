import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/category_books.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_cached_category_books_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_category_books_use_case.dart';

part 'book_data_state.dart';

class BookDataCubit extends Cubit<BookDataState> {
  final GetCachedCategoryBooksUseCase _getCachedCategoryBooks;
  final GetCategoryBooksUseCase _getCategoryBooks;
  BookDataCubit(this._getCachedCategoryBooks, this._getCategoryBooks)
    : super(BookDataInitial());

  Future<void> emitGetBookData(String id) async {
    log('📚 [BookDataCubit] Fetching book data for: $id');

    final cached = await _getCachedCategoryBooks(id);

    if (cached != null) {
      log('✅ [BookDataCubit] CACHE HIT - category: ${cached.category?.name ?? "N/A"}');
      emit(BookDataSuccess(cached, isFromCache: true, isRefreshing: true));

      _backgroundRefresh(id);
    } else {
      log('❌ [BookDataCubit] CACHE MISS - Fetching from API');
      emit(BookDataLoading());
      final result = await _getCategoryBooks(id);
      result.when(
        success: (data) {
          log('🟢 [BookDataCubit] API SUCCESS - category: ${data.category?.name ?? "N/A"}');
          emit(BookDataSuccess(data));
        },
        failure: (failure) {
          log('🔴 [BookDataCubit] API ERROR: ${failure.message}');
          emit(BookDataFailure(failure.message));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(String id) async {
    log('🔄 [BookDataCubit] Background refresh started for: $id');
    final result = await _getCategoryBooks(id);
    result.when(
      success: (data) {
        log('🟢 [BookDataCubit] Background refresh SUCCESS');
        emit(BookDataSuccess(data, isFromCache: false, isRefreshing: false));
      },
      failure: (failure) {
        log('⚠️ [BookDataCubit] Background refresh FAILED: ${failure.message}');
        if (state is BookDataSuccess) {
          emit((state as BookDataSuccess).copyWith(isRefreshing: false));
        }
      },
    );
  }
}
