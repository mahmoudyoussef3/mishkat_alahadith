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
    // Try cache first
    final cached = await _bookMarkRepo.getCachedBookmarks();

    if (cached != null && cached.bookmarks != null) {
      // Emit cached data immediately
      emit(
        UserBookmarksSuccess(
          cached.bookmarks!,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      // Background refresh
      _backgroundRefresh(cached.bookmarks!);
    } else {
      // No cache, fetch from API
      emit(GetBookmarksLoading());
      final result = await _bookMarkRepo.getUserBookMarks();
      result.fold(
        (l) => emit(GetBookmarksFailure(l.getAllErrorMessages())),
        (r) => emit(UserBookmarksSuccess(r.bookmarks ?? [])),
      );
    }
  }

  Future<void> _backgroundRefresh(List<Bookmark> cached) async {
    final result = await _bookMarkRepo.getUserBookMarks();
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is UserBookmarksSuccess) {
          emit((state as UserBookmarksSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        emit(
          UserBookmarksSuccess(
            response.bookmarks ?? [],
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  Future<void> deleteBookmark(int hadithId) async {
    final result = await _bookMarkRepo.deleteBookMark(hadithId);
    result.fold(
      (l) => emit(GetBookmarksFailure(l.getAllErrorMessages())),
      (r) => getUserBookmarks(),
    );
  }
}
