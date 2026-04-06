import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/repos/chapters_repo.dart';

part 'chapters_state.dart';

class ChaptersCubit extends Cubit<ChaptersState> {
  final BookChaptersRepo _bookChaptersRepo;
  ChaptersCubit(this._bookChaptersRepo) : super(ChaptersInitial());

  Future<void> emitGetBookChapters({required String bookSlug}) async {
    log('📚 [ChaptersCubit] Fetching chapters for: $bookSlug');
    
    // Try cache first
    final cached = await _bookChaptersRepo.getCachedChapters(bookSlug);

    if (cached != null && (cached.chapters?.isNotEmpty ?? false)) {
      log('✅ [ChaptersCubit] CACHE HIT - ${cached.chapters!.length} chapters');
      // Emit cached data immediately
      emit(
        ChaptersSuccess(
          allChapters: cached.chapters!,
          filteredChapters: cached.chapters!,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      // Background refresh
      _backgroundRefresh(bookSlug, cached.chapters!);
    } else {
      log('❌ [ChaptersCubit] CACHE MISS - Fetching from API');
      // No cache, fetch from API
      emit(ChaptersLoading());
      final result = await _bookChaptersRepo.getBookChapters(bookSlug);
      result.fold(
        (l) {
          log('🔴 [ChaptersCubit] API ERROR: ${l.getAllErrorMessages()}');
          emit(ChaptersFailure(l.getAllErrorMessages()));
        },
        (r) {
          log('🟢 [ChaptersCubit] API SUCCESS - ${r.chapters?.length ?? 0} chapters');
          emit(
            ChaptersSuccess(
              allChapters: r.chapters ?? [],
              filteredChapters: r.chapters ?? [],
            ),
          );
        },
      );
    }
  }

  Future<void> _backgroundRefresh(
    String bookSlug,
    List<Chapter> cachedChapters,
  ) async {
    log('🔄 [ChaptersCubit] Background refresh started for: $bookSlug');
    final result = await _bookChaptersRepo.getBookChapters(bookSlug);
    result.fold(
      (error) {
        log('⚠️ [ChaptersCubit] Background refresh FAILED: ${error.getAllErrorMessages()}');
        // Background refresh failed, keep cached data
        if (state is ChaptersSuccess) {
          emit((state as ChaptersSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        final newChapters = response.chapters ?? [];
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
              return normalizedChapter.contains(normalizedQuery.trim());
            }).toList();

        emit(currentState.copyWith(filteredChapters: filtered));
      }
    }
  }

  String normalizeArabic(String text) {
    final diacritics = RegExp(r'[\u0617-\u061A\u064B-\u0652]');
    String result = text.replaceAll(diacritics, '');
    result = result.replaceAll(RegExp('[إأآ]'), 'ا');
    result = result.replaceAll('ـ', '');
    result = result.toLowerCase();
    return result;
  }
}
