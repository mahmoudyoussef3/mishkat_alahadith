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
    // Try cache first
    final cached = await _bookMarkRepo.getCachedCollections();

    if (cached != null) {
      // Emit cached data immediately
      emit(
        GetCollectionsBookmarkSuccess(
          cached,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      // Background refresh
      _backgroundRefresh(cached);
    } else {
      // No cache, fetch from API
      emit(GetCollectionsBookmarkLoading());
      final result = await _bookMarkRepo.getBookmarkCollectionsRepo();
      result.fold(
        (l) => emit(GetCollectionsBookmarkError(l.getAllErrorMessages())),
        (r) => emit(GetCollectionsBookmarkSuccess(r)),
      );
    }
  }

  Future<void> _backgroundRefresh(CollectionsResponse cached) async {
    final result = await _bookMarkRepo.getBookmarkCollectionsRepo();
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is GetCollectionsBookmarkSuccess) {
          emit(
            (state as GetCollectionsBookmarkSuccess).copyWith(
              isRefreshing: false,
            ),
          );
        }
      },
      (response) {
        emit(
          GetCollectionsBookmarkSuccess(
            response,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
