import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_action_result.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/add_bookmark_use_case.dart';

part 'add_cubit_state.dart';

class AddCubitCubit extends Cubit<AddCubitState> {
  final AddBookmarkUseCase _addBookmark;
  AddCubitCubit(this._addBookmark) : super(AddCubitInitial());

  Future<void> addBookmark(UserBookmark body) async {
    emit(AddLoading());
    final result = await _addBookmark(body);

    result.when(
      success: (response) => emit(AddSuccess(response)),
      failure: (failure) => emit(AddFailure(failure.message)),
    );
  }
}
