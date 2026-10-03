import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_book_chapters_use_case.dart';
import 'package:mishkat_almasabih/features/chapters/domain/usecases/get_cached_book_chapters_use_case.dart';

part 'chapters_state.dart';

class ChaptersCubit extends Cubit<ChaptersState> {
  final GetCachedBookChaptersUseCase _getCachedChapters;
  final GetBookChaptersUseCase _getChapters;
  ChaptersCubit(this._getCachedChapters, this._getChapters)
    : super(ChaptersInitial());

  Future<void> emitGetBookChapters({required String bookSlug}) async {
    log('📚 [ChaptersCubit] Fetching chapters for: $bookSlug');

    final cached = await _getCachedChapters(bookSlug);

    if (cached != null && cached.isNotEmpty) {
      log('✅ [ChaptersCubit] CACHE HIT - ${cached.length} chapters');
      emit(
        ChaptersSuccess(
          allChapters: cached,
          filteredChapters: cached,
          isFromCache: true,
          isRefreshing: true,
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
          emit(ChaptersSuccess(allChapters: chapters, filteredChapters: chapters));
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
