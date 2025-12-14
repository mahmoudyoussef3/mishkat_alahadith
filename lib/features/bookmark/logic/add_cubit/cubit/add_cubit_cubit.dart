import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_response.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/book_mark_repo.dart';

part 'add_cubit_state.dart';

class AddCubitCubit extends Cubit<AddCubitState> {
  final BookMarkRepo _bookMarkRepo;
  AddCubitCubit(this._bookMarkRepo) : super(AddCubitInitial());

  Future<void> addBookmark(Bookmark body) async {
    emit(AddLoading());
    final result = await _bookMarkRepo.addBookmark(body);

    result.fold(
      (l) => emit(AddFailure(l.getAllErrorMessages())),
      (r) => emit(AddSuccess(r)),
    );
  }
}
