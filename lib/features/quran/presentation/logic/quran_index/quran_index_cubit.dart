import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_page_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_juz_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/remove_quran_bookmark_use_case.dart';

part 'quran_index_state.dart';

class QuranIndexCubit extends Cubit<QuranIndexState> {
  final GetSurahsUseCase _getSurahs;
  final GetJuzIndexUseCase _getJuzIndex;
  final FilterSurahsUseCase _filterSurahs;
  final GetQuranBookmarksUseCase _getBookmarks;
  final RemoveQuranBookmarkUseCase _removeBookmark;
  final GetLastReadUseCase _getLastRead;
  final GetPageInfoUseCase _getPageInfo;

  QuranIndexCubit(
    this._getSurahs,
    this._getJuzIndex,
    this._filterSurahs,
    this._getBookmarks,
    this._removeBookmark,
    this._getLastRead,
    this._getPageInfo,
  ) : super(const QuranIndexLoading());

  Future<void> load() async {
    emit(const QuranIndexLoading());
    final results = await (_getSurahs(), _getJuzIndex()).wait;
    if (isClosed) return;

    switch (results) {
      case (ApiFailure(:final failure), _):
      case (_, ApiFailure(:final failure)):
        emit(QuranIndexFailure(failure.message));
      case (ApiSuccess(data: final surahs), ApiSuccess(data: final juzList)):
        final reading = await _loadReadingData();
        if (isClosed) return;
        emit(
          QuranIndexLoaded(
            surahs: surahs,
            visibleSurahs: surahs,
            query: '',
            juzList: juzList,
            bookmarks: reading.bookmarks,
            lastRead: reading.lastRead,
            lastReadInfo: reading.lastReadInfo,
          ),
        );
    }
  }

  /// Picks up what the reader changed: the last page and the bookmarks.
  Future<void> refreshReadingData() async {
    if (state is! QuranIndexLoaded) return;
    final reading = await _loadReadingData();
    final latest = state;
    if (isClosed || latest is! QuranIndexLoaded) return;
    emit(
      latest.copyWith(
        bookmarks: () => reading.bookmarks,
        lastRead: () => reading.lastRead,
        lastReadInfo: () => reading.lastReadInfo,
      ),
    );
  }

  void filterSurahs(String query) {
    final current = state;
    if (current is! QuranIndexLoaded) return;
    emit(
      current.copyWith(
        query: query,
        visibleSurahs: _filterSurahs(current.surahs, query),
      ),
    );
  }

  Future<bool> removeBookmark(QuranBookmark bookmark) async {
    final result = await _removeBookmark(bookmark);
    if (result is ApiFailure) return false;
    await refreshReadingData();
    return true;
  }

  Future<
    ({
      List<QuranBookmark>? bookmarks,
      QuranLastRead? lastRead,
      QuranPageInfo? lastReadInfo,
    })
  >
  _loadReadingData() async {
    final (bookmarksResult, lastReadResult) =
        await (_getBookmarks(), _getLastRead()).wait;

    final lastRead = switch (lastReadResult) {
      ApiSuccess(:final data) => data,
      ApiFailure() => null,
    };
    final lastReadInfo =
        lastRead == null
            ? null
            : switch (await _getPageInfo(lastRead.page)) {
              ApiSuccess(:final data) => data,
              ApiFailure() => null,
            };

    return (
      bookmarks: switch (bookmarksResult) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      },
      lastRead: lastRead,
      lastReadInfo: lastReadInfo,
    );
  }
}
