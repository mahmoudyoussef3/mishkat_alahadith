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
    // Try cache first
    final cached = await bookDataRepo.getCachedBookData(id);

    if (cached != null) {
      // Emit cached data immediately
      emit(BookDataSuccess(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(id, cached);
    } else {
      // No cache, fetch from API
      emit(BookDataLoading());
      final result = await bookDataRepo.getBookData(id);
      result.fold(
        (l) => emit(BookDataFailure(l.getAllErrorMessages())),
        (r) => emit(BookDataSuccess(r)),
      );
    }
  }

  Future<void> _backgroundRefresh(String id, CategoryResponse cached) async {
    final result = await bookDataRepo.getBookData(id);
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is BookDataSuccess) {
          emit((state as BookDataSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        emit(
          BookDataSuccess(response, isFromCache: false, isRefreshing: false),
        );
      },
    );
  }
}
