import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/book_mark_repo.dart';

part 'user_bookmarks_state.dart';

class GetBookmarksCubit extends Cubit<GetBookmarksState> {
  final BookMarkRepo _bookMarkRepo;
  GetBookmarksCubit(this._bookMarkRepo) : super(GetBookmarksInitial());

  Future<void> getUserBookmarks() async {
    emit(GetBookmarksLoading());
    final result = await _bookMarkRepo.getUserBookMarks();

    result.fold(
      (l) => emit(GetBookmarksFailure(l.getAllErrorMessages())),
      (r) => emit(UserBookmarksSuccess(r.bookmarks!)),
    );
  }
}
