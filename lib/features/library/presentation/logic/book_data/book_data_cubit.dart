import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/book_data/data/repos/book_data_repo.dart';

part 'book_data_state.dart';

class BookDataCubit extends Cubit<BookDataState> {
  GetBookDataRepo bookDataRepo;
  BookDataCubit(this.bookDataRepo) : super(BookDataInitial());

  Future<void> emitGetBookData(String id) async {
    log('📚 [BookDataCubit] Fetching book data for: $id');
    
    // Try cache first
    final cached = await bookDataRepo.getCachedBookData(id);

    if (cached != null) {
      log('✅ [BookDataCubit] CACHE HIT - category: ${cached.category?.name ?? "N/A"}');
      // Emit cached data immediately
      emit(BookDataSuccess(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(id, cached);
    } else {
      log('❌ [BookDataCubit] CACHE MISS - Fetching from API');
      // No cache, fetch from API
      emit(BookDataLoading());
      final result = await bookDataRepo.getBookData(id);
      result.fold(
        (l) {
          log('🔴 [BookDataCubit] API ERROR: ${l.getAllErrorMessages()}');
          emit(BookDataFailure(l.getAllErrorMessages()));
        },
        (r) {
          log('🟢 [BookDataCubit] API SUCCESS - category: ${r.category?.name ?? "N/A"}');
          emit(BookDataSuccess(r));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(String id, CategoryResponse cached) async {
    log('🔄 [BookDataCubit] Background refresh started for: $id');
    final result = await bookDataRepo.getBookData(id);
    result.fold(
      (error) {
        log('⚠️ [BookDataCubit] Background refresh FAILED: ${error.getAllErrorMessages()}');
        // Background refresh failed, keep cached data
        if (state is BookDataSuccess) {
          emit((state as BookDataSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        log('🟢 [BookDataCubit] Background refresh SUCCESS');
        emit(
          BookDataSuccess(response, isFromCache: false, isRefreshing: false),
        );
      },
    );
  }
}
