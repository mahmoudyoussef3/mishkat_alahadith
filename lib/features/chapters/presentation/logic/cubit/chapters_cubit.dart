import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/last_read_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_book_chapters_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_cached_book_chapters_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_last_read_chapter_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/save_last_read_chapter_use_case.dart';

part 'chapters_state.dart';

class ChaptersCubit extends Cubit<ChaptersState> {
  final GetCachedBookChaptersUseCase _getCachedChapters;
  final GetBookChaptersUseCase _getChapters;
  final GetLastReadChapterUseCase _getLastRead;
  final SaveLastReadChapterUseCase _saveLastRead;
  ChaptersCubit(
    this._getCachedChapters,
    this._getChapters,
    this._getLastRead,
    this._saveLastRead,
  ) : super(ChaptersInitial());

  String? _bookSlug;
  LastReadChapter? _lastRead;

  Future<void> emitGetBookChapters({required String bookSlug}) async {
    log('📚 [ChaptersCubit] Fetching chapters for: $bookSlug');
    _bookSlug = bookSlug;
    if (await _getLastRead(bookSlug) case ApiSuccess(:final data)) {
      _lastRead = data;
    }

    final cached = await _getCachedChapters(bookSlug);

    if (cached != null && cached.isNotEmpty) {
      log('✅ [ChaptersCubit] CACHE HIT - ${cached.length} chapters');
      emit(
        ChaptersSuccess(
          allChapters: cached,
          filteredChapters: cached,
          isFromCache: true,
          isRefreshing: true,
          lastRead: _lastRead,
        ),
      );

      _backgroundRefresh(bookSlug);
    } else {
      log('❌ [ChaptersCubit] CACHE MISS - Fetching from API');
      emit(ChaptersLoading());
      final result = await _getChapters(bookSlug);
      result.when(
        success: (chapters) {
          log('🟢 [ChaptersCubit] API SUCCESS - ${chapters.length} chapters');
          emit(
            ChaptersSuccess(
              allChapters: chapters,
              filteredChapters: chapters,
              lastRead: _lastRead,
            ),
          );
        },
        failure: (failure) {
          log('🔴 [ChaptersCubit] API ERROR: ${failure.message}');
          emit(ChaptersFailure(failure.message));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(String bookSlug) async {
    log('🔄 [ChaptersCubit] Background refresh started for: $bookSlug');
    final result = await _getChapters(bookSlug);
    result.when(
      success: (newChapters) {
        log('🟢 [ChaptersCubit] Background refresh SUCCESS - ${newChapters.length} chapters');
        if (newChapters.isEmpty) {
          if (state is ChaptersSuccess) {
            emit((state as ChaptersSuccess).copyWith(isRefreshing: false));
          }
          return;
        }

        emit(
          ChaptersSuccess(
            allChapters: newChapters,
            filteredChapters: newChapters,
            isFromCache: false,
            isRefreshing: false,
            lastRead: _lastRead,
          ),
        );
      },
      failure: (failure) {
        log('⚠️ [ChaptersCubit] Background refresh FAILED: ${failure.message}');
        if (state is ChaptersSuccess) {
          emit((state as ChaptersSuccess).copyWith(isRefreshing: false));
        }
      },
    );
  }

  /// Remembers [chapter] as where the reader is, for "continue reading".
  Future<void> markChapterOpened(BookChapter chapter) async {
    final bookSlug = _bookSlug;
    final number = chapter.chapterNumber;
    if (bookSlug == null || number == null) return;

    final lastRead = LastReadChapter(
      chapterNumber: number,
      title: chapter.chapterArabic ?? '',
    );
    _lastRead = lastRead;
    if (state case final ChaptersSuccess current) {
      emit(current.copyWith(lastRead: lastRead));
    }
    await _saveLastRead(bookSlug, lastRead);
  }

  void filterChapters(String query) {
    if (state is ChaptersSuccess) {
      final currentState = state as ChaptersSuccess;
      final normalizedQuery = normalizeArabic(query);

      if (normalizedQuery.isEmpty) {
        emit(currentState.copyWith(filteredChapters: currentState.allChapters));
      } else {
        final filtered =
            currentState.allChapters.where((chapter) {
              final normalizedChapter = normalizeArabic(
                chapter.chapterArabic ?? '',
              );
              return normalizedChapter.contains(normalizedQuery);
            }).toList();

        emit(currentState.copyWith(filteredChapters: filtered));
      }
    }
  }
}
