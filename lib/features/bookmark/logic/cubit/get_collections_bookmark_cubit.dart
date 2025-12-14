import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/repos/book_mark_repo.dart';

part 'get_collections_bookmark_state.dart';

class GetCollectionsBookmarkCubit extends Cubit<GetCollectionsBookmarkState> {
  final BookMarkRepo _bookMarkRepo;
  GetCollectionsBookmarkCubit(this._bookMarkRepo)
    : super(GetCollectionsBookmarkInitial());

  Future<void> getBookMarkCollections() async {
    emit(GetCollectionsBookmarkLoading());
    final result = await _bookMarkRepo.getBookmarkCollectionsRepo();

    result.fold(
      (l) => emit(GetCollectionsBookmarkError(l.getAllErrorMessages())),
      (r) => emit(GetCollectionsBookmarkSuccess(r)),
    );
  }
}
