import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/entities/user_bookmark.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/delete_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/bookmark/domain/usecases/get_cached_bookmarks_use_case.dart';

part 'user_bookmarks_state.dart';

class GetBookmarksCubit extends Cubit<GetBookmarksState> {
  final GetCachedBookmarksUseCase _getCachedBookmarks;
  final GetBookmarksUseCase _getBookmarks;
  final DeleteBookmarkUseCase _deleteBookmark;
  GetBookmarksCubit(
    this._getCachedBookmarks,
    this._getBookmarks,
    this._deleteBookmark,
  ) : super(GetBookmarksInitial());

  Future<void> getUserBookmarks() async {
    log('🔖 [BookmarksCubit] Fetching user bookmarks');

    final cached = await _getCachedBookmarks();

    if (cached != null) {
      log('✅ [BookmarksCubit] CACHE HIT - ${cached.length} bookmarks');
      emit(UserBookmarksSuccess(cached, isFromCache: true, isRefreshing: true));

      _backgroundRefresh();
    } else {
      log('❌ [BookmarksCubit] CACHE MISS - Fetching from API');
      emit(GetBookmarksLoading());
      final result = await _getBookmarks();
      result.when(
        success: (bookmarks) {
          log(
            '🟢 [BookmarksCubit] API SUCCESS - ${bookmarks.length} bookmarks',
          );
          emit(UserBookmarksSuccess(bookmarks));
        },
        failure: (failure) {
          log('🔴 [BookmarksCubit] API ERROR: ${failure.message}');
          emit(GetBookmarksFailure(failure.message));
        },
      );
    }
  }

  Future<void> _backgroundRefresh() async {
    log('🔄 [BookmarksCubit] Background refresh started');
    final result = await _getBookmarks();
    result.when(
      success: (bookmarks) {
        log(
          '🟢 [BookmarksCubit] Background refresh SUCCESS - ${bookmarks.length} bookmarks',
        );
        emit(
          UserBookmarksSuccess(
            bookmarks,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
      failure: (failure) {
        log(
          '⚠️ [BookmarksCubit] Background refresh FAILED: ${failure.message}',
        );
        if (state is UserBookmarksSuccess) {
          emit((state as UserBookmarksSuccess).copyWith(isRefreshing: false));
        }
      },
    );
  }

  Future<void> deleteBookmark(int hadithId) async {
    log('🗑️ [BookmarksCubit] Deleting bookmark: $hadithId');
    final result = await _deleteBookmark(hadithId);
    result.when(
      success: (_) {
        log('🟢 [BookmarksCubit] Delete SUCCESS - refreshing list');
        getUserBookmarks();
      },
      failure: (failure) {
        log('🔴 [BookmarksCubit] Delete ERROR: ${failure.message}');
        emit(GetBookmarksFailure(failure.message));
      },
    );
  }
}
