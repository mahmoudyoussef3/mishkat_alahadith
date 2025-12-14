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
    log('message');
    emit(BookDataLoading());
    final result = await bookDataRepo.getBookData(id);
    result.fold((l) {


      emit(BookDataFailure(l.getAllErrorMessages()));
    }, (r) => emit(BookDataSuccess(r)));
  }
}
