import 'dart:developer';
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
    log('🔖 [BookmarksCubit] Fetching user bookmarks');
    
    // Try cache first
    final cached = await _bookMarkRepo.getCachedBookmarks();

    if (cached != null && cached.bookmarks != null) {
      log('✅ [BookmarksCubit] CACHE HIT - ${cached.bookmarks!.length} bookmarks');
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
      log('❌ [BookmarksCubit] CACHE MISS - Fetching from API');
      // No cache, fetch from API
      emit(GetBookmarksLoading());
      final result = await _bookMarkRepo.getUserBookMarks();
      result.fold(
        (l) {
          log('🔴 [BookmarksCubit] API ERROR: ${l.getAllErrorMessages()}');
          emit(GetBookmarksFailure(l.getAllErrorMessages()));
        },
        (r) {
          log('🟢 [BookmarksCubit] API SUCCESS - ${r.bookmarks?.length ?? 0} bookmarks');
          emit(UserBookmarksSuccess(r.bookmarks ?? []));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(List<Bookmark> cached) async {
    log('🔄 [BookmarksCubit] Background refresh started');
    final result = await _bookMarkRepo.getUserBookMarks();
    result.fold(
      (error) {
        log('⚠️ [BookmarksCubit] Background refresh FAILED: ${error.getAllErrorMessages()}');
        // Background refresh failed, keep cached data
        if (state is UserBookmarksSuccess) {
          emit((state as UserBookmarksSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        log('🟢 [BookmarksCubit] Background refresh SUCCESS - ${response.bookmarks?.length ?? 0} bookmarks');
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
    log('🗑️ [BookmarksCubit] Deleting bookmark: $hadithId');
    final result = await _bookMarkRepo.deleteBookMark(hadithId);
    result.fold(
      (l) {
        log('🔴 [BookmarksCubit] Delete ERROR: ${l.getAllErrorMessages()}');
        emit(GetBookmarksFailure(l.getAllErrorMessages()));
      },
      (r) {
        log('🟢 [BookmarksCubit] Delete SUCCESS - refreshing list');
        getUserBookmarks();
      },
    );
  }
}
