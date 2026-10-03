import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/entities/local_book_hadith.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/cache_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_arbain_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_cached_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_chapter_ahadith_page_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_local_ahadith_use_case.dart';
part 'ahadiths_state.dart';

class AhadithsCubit extends Cubit<AhadithsState> {
  final GetCachedChapterAhadithUseCase _getCachedAhadith;
  final CacheChapterAhadithUseCase _cacheAhadith;
  final GetChapterAhadithPageUseCase _getAhadithPage;
  final GetLocalAhadithUseCase _getLocalAhadith;
  final GetArbainAhadithUseCase _getArbainAhadith;
  AhadithsCubit(
    this._getCachedAhadith,
    this._cacheAhadith,
    this._getAhadithPage,
    this._getLocalAhadith,
    this._getArbainAhadith,
  ) : super(AhadithsInitial());

  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _lastSourceKey;
  int _currentPage = 1;

  Future<void> emitAhadiths({
    required String bookSlug,
    required int chapterId,
    required bool hadithLocal,
    required bool isArbainBooks,
    required int page,
    int paginate = 10,
  }) async {
    final currentSourceKey = '$bookSlug-$chapterId-$hadithLocal-$isArbainBooks';

    if (_lastSourceKey != currentSourceKey) {
      _hasMore = true;
      _isLoadingMore = false;
      _currentPage = 1;
      emit(AhadithsInitial());
      _lastSourceKey = currentSourceKey;
    }

    if (page == 1) {
      await _loadFirstPageWithCache(
        bookSlug: bookSlug,
        chapterId: chapterId,
        hadithLocal: hadithLocal,
        isArbainBooks: isArbainBooks,
        paginate: paginate,
      );
      return;
    }

    await _loadMorePages(
      bookSlug: bookSlug,
      chapterId: chapterId,
      hadithLocal: hadithLocal,
      isArbainBooks: isArbainBooks,
      page: page,
      paginate: paginate,
    );
  }

  Future<void> _loadFirstPageWithCache({
    required String bookSlug,
    required int chapterId,
    required bool hadithLocal,
    required bool isArbainBooks,
    required int paginate,
  }) async {
    log('📖 [AhadithsCubit] Loading first page - book: $bookSlug, chapter: $chapterId');

    if (isArbainBooks || hadithLocal) {
      log('📚 [AhadithsCubit] Local/Arbain book - skipping cache');
      emit(AhadithsLoading());
      await _loadLocalBooks(
        bookSlug: bookSlug,
        chapterId: chapterId,
        isArbainBooks: isArbainBooks,
      );
      return;
    }

    final cached = await _getCachedAhadith(
      bookSlug: bookSlug,
      chapterId: chapterId,
    );

    if (cached != null && cached.ahadith.isNotEmpty) {
      log('✅ [AhadithsCubit] CACHE HIT - ${cached.ahadith.length} ahadith, page ${cached.lastLoadedPage}');
      _currentPage = cached.lastLoadedPage;
      _hasMore = cached.ahadith.length < cached.totalCount;

      emit(
        AhadithsSuccess(
          allAhadith: cached.ahadith,
          filteredAhadith: cached.ahadith,
          isFromCache: true,
          hasMoreData: _hasMore,
          isRefreshing: true,
        ),
      );

      _backgroundRefresh(
        bookSlug: bookSlug,
        chapterId: chapterId,
        paginate: paginate,
        cachedAhadith: cached.ahadith,
      );
    } else {
      log('❌ [AhadithsCubit] CACHE MISS - Fetching from API');
      emit(AhadithsLoading());
      await _fetchFromApi(
        bookSlug: bookSlug,
        chapterId: chapterId,
        page: 1,
        paginate: paginate,
        existingAhadith: [],
      );
    }
  }

  Future<void> _backgroundRefresh({
    required String bookSlug,
    required int chapterId,
    required int paginate,
    required List<ChapterHadith> cachedAhadith,
  }) async {
    log('🔄 [AhadithsCubit] Background refresh started - book: $bookSlug, chapter: $chapterId');
    final result = await _getAhadithPage(
      bookSlug: bookSlug,
      chapterId: chapterId,
      page: 1,
      paginate: paginate,
    );

    result.when(
      success: (page) {
        final newAhadith = page.ahadith;
        log('🟢 [AhadithsCubit] Background refresh SUCCESS - ${newAhadith.length} ahadith, total: ${page.total}');

        if (newAhadith.isEmpty) {
          if (state is AhadithsSuccess) {
            emit((state as AhadithsSuccess).copyWith(isRefreshing: false));
          }
          return;
        }

        final merged = cachedAhadith.refreshedWith(newAhadith);
        log('📊 [AhadithsCubit] Merged: ${merged.length} ahadith (new: ${newAhadith.length}, cached: ${cachedAhadith.length})');
        _hasMore = 1 < page.totalPages;
        _currentPage = 1;

        _cacheAhadith(
          bookSlug: bookSlug,
          chapterId: chapterId,
          ahadith: merged,
          lastLoadedPage: _currentPage,
          totalCount: page.total,
        );

        emit(
          AhadithsSuccess(
            allAhadith: merged,
            filteredAhadith: merged,
            isFromCache: false,
            isRefreshing: false,
            hasMoreData: _hasMore,
          ),
        );
      },
      failure: (failure) {
        log('⚠️ [AhadithsCubit] Background refresh FAILED: ${failure.message}');
        if (state is AhadithsSuccess) {
          emit((state as AhadithsSuccess).copyWith(isRefreshing: false));
        }
      },
    );
  }

  Future<void> _loadMorePages({
    required String bookSlug,
    required int chapterId,
    required bool hadithLocal,
    required bool isArbainBooks,
    required int page,
    required int paginate,
  }) async {
    if (_isLoadingMore || !_hasMore) {
      log('⏸️ [AhadithsCubit] Load more skipped - loading: $_isLoadingMore, hasMore: $_hasMore');
      return;
    }
    if (hadithLocal || isArbainBooks) return;

    log('📖 [AhadithsCubit] Loading more - page $page');
    _isLoadingMore = true;

    if (state is AhadithsSuccess) {
      emit((state as AhadithsSuccess).copyWith(isLoadingMore: true));
    }

    final currentAhadith =
        state is AhadithsSuccess
            ? (state as AhadithsSuccess).allAhadith
            : <ChapterHadith>[];

    await _fetchFromApi(
      bookSlug: bookSlug,
      chapterId: chapterId,
      page: page,
      paginate: paginate,
      existingAhadith: currentAhadith,
    );
  }

  Future<void> _fetchFromApi({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
    required List<ChapterHadith> existingAhadith,
  }) async {
    log('🌐 [AhadithsCubit] API fetch - page: $page, book: $bookSlug, chapter: $chapterId');
    final result = await _getAhadithPage(
      bookSlug: bookSlug,
      chapterId: chapterId,
      page: page,
      paginate: paginate,
    );

    result.when(
      success: (response) {
        final newAhadith = response.ahadith;
        final totalPages = response.totalPages;
        log('🟢 [AhadithsCubit] API SUCCESS - page $page/$totalPages, got ${newAhadith.length} ahadith');

        if (newAhadith.isEmpty) {
          _hasMore = false;
        } else {
          _hasMore = page < totalPages;
        }

        final merged = existingAhadith.appendUnique(newAhadith);
        log('📊 [AhadithsCubit] Merged: ${merged.length} total (existing: ${existingAhadith.length}, new: ${newAhadith.length})');
        _currentPage = page;
        _isLoadingMore = false;

        _cacheAhadith(
          bookSlug: bookSlug,
          chapterId: chapterId,
          ahadith: merged,
          lastLoadedPage: _currentPage,
          totalCount: response.total,
        );

        emit(
          AhadithsSuccess(
            allAhadith: merged,
            filteredAhadith: merged,
            isLoadingMore: false,
            hasMoreData: _hasMore,
          ),
        );
      },
      failure: (failure) {
        log('🔴 [AhadithsCubit] API ERROR: ${failure.message}');
        _isLoadingMore = false;
        if (existingAhadith.isEmpty) {
          emit(AhadithsFailure(failure.message));
        } else {
          emit(
            AhadithsSuccess(
              allAhadith: existingAhadith,
              filteredAhadith: existingAhadith,
              isLoadingMore: false,
              hasMoreData: _hasMore,
            ),
          );
        }
      },
    );
  }

  Future<void> _loadLocalBooks({
    required String bookSlug,
    required int chapterId,
    required bool isArbainBooks,
  }) async {
    final result =
        isArbainBooks
            ? await _getArbainAhadith(bookSlug: bookSlug, chapterId: chapterId)
            : await _getLocalAhadith(bookSlug: bookSlug, chapterId: chapterId);

    result.when(
      success: (hadiths) => emit(LocalAhadithsSuccess(hadiths: hadiths)),
      failure: (failure) => emit(AhadithsFailure(failure.message)),
    );
  }

  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  void filterAhadith(String query) {
    final currentState = state;
    final normalizedQuery = normalizeArabic(query);

    if (currentState is AhadithsSuccess) {
      if (normalizedQuery.isEmpty) {
        emit(currentState.copyWith(filteredAhadith: currentState.allAhadith));
      } else {
        final filtered =
            currentState.allAhadith
                .where(
                  (h) =>
                      h.hadithArabic != null &&
                      normalizeArabic(
                        h.hadithArabic!,
                      ).contains(normalizedQuery),
                )
                .toList();
        emit(currentState.copyWith(filteredAhadith: filtered));
      }
    } else if (currentState is LocalAhadithsSuccess) {
      if (normalizedQuery.isEmpty) {
        emit(currentState.copyWith(filteredHadiths: currentState.hadiths));
      } else {
        final filtered =
            currentState.hadiths
                .where(
                  (h) =>
                      h.arabic != null &&
                      normalizeArabic(h.arabic!).contains(normalizedQuery),
                )
                .toList();
        emit(currentState.copyWith(filteredHadiths: filtered));
      }
    }
  }
}
