import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/bookmark_action_result.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/delete_bookmark_use_case.dart';

part 'delete_cubit_state.dart';

class DeleteCubitCubit extends Cubit<DeleteCubitState> {
  final DeleteBookmarkUseCase _deleteBookmark;
  DeleteCubitCubit(this._deleteBookmark) : super(DeleteCubitInitial());

  Future<void> delete(int id) async {
    emit(DeleteLoading());
    final result = await _deleteBookmark(id);

    result.when(
      success: (response) => emit(DeleteSuccess(response)),
      failure: (failure) => emit(DeleteFaliure(failure.message)),
    );
  }
}
