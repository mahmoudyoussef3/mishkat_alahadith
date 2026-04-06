import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/helpers/functions.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/repos/ahadiths_repo.dart';
part 'ahadiths_state.dart';

class AhadithsCubit extends Cubit<AhadithsState> {
  final AhadithsRepo _chapterAhadithsRepo;
  AhadithsCubit(this._chapterAhadithsRepo) : super(AhadithsInitial());

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

    // Reset state when source changes
    if (_lastSourceKey != currentSourceKey) {
      _hasMore = true;
      _isLoadingMore = false;
      _currentPage = 1;
      emit(AhadithsInitial());
      _lastSourceKey = currentSourceKey;
    }

    // Handle first page with cache-first strategy
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

    // Handle pagination (page > 1)
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
    // Local books don't use cache/pagination
    if (isArbainBooks || hadithLocal) {
      emit(AhadithsLoading());
      await _loadLocalBooks(
        bookSlug: bookSlug,
        chapterId: chapterId,
        isArbainBooks: isArbainBooks,
      );
      return;
    }

    // Try cache first
    final cached = await _chapterAhadithsRepo.getCachedAhadith(
      bookSlug: bookSlug,
      chapterId: chapterId,
    );

    if (cached != null && cached.ahadith.isNotEmpty) {
      // Emit cached data immediately
      _currentPage = cached.lastPage;
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

      // Background sync: fetch fresh data
      _backgroundRefresh(
        bookSlug: bookSlug,
        chapterId: chapterId,
        paginate: paginate,
        cachedAhadith: cached.ahadith,
      );
    } else {
      // No cache, fetch from API
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
    required List<Hadith> cachedAhadith,
  }) async {
    final result = await _chapterAhadithsRepo.getAhadith(
      bookSlug: bookSlug,
      chapterId: chapterId,
      page: 1,
      paginate: paginate,
    );

    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is AhadithsSuccess) {
          emit((state as AhadithsSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        final newAhadith = response.hadiths?.data ?? [];
        final totalPages = response.hadiths?.last_page ?? 1;
        final total = response.hadiths?.total ?? 0;

        if (newAhadith.isEmpty) {
          if (state is AhadithsSuccess) {
            emit((state as AhadithsSuccess).copyWith(isRefreshing: false));
          }
          return;
        }

        // Merge with cache (new data takes precedence by checking IDs)
        final merged = _mergeWithPriority(newAhadith, cachedAhadith);
        _hasMore = 1 < totalPages;
        _currentPage = 1;

        // Update cache
        _chapterAhadithsRepo.cacheAhadith(
          bookSlug: bookSlug,
          chapterId: chapterId,
          ahadith: merged,
          lastPage: _currentPage,
          totalCount: total,
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
    );
  }

  /// Merges new data with cache, prioritizing new data and removing duplicates
  List<Hadith> _mergeWithPriority(List<Hadith> newItems, List<Hadith> cached) {
    final newIds = newItems.map((h) => h.id).toSet();
    final uniqueCached = cached.where((h) => !newIds.contains(h.id)).toList();
    return [...newItems, ...uniqueCached];
  }

  Future<void> _loadMorePages({
    required String bookSlug,
    required int chapterId,
    required bool hadithLocal,
    required bool isArbainBooks,
    required int page,
    required int paginate,
  }) async {
    if (_isLoadingMore || !_hasMore) return;
    if (hadithLocal || isArbainBooks) return; // No pagination for local books

    _isLoadingMore = true;

    // Emit loading more state
    if (state is AhadithsSuccess) {
      emit((state as AhadithsSuccess).copyWith(isLoadingMore: true));
    }

    final currentAhadith =
        state is AhadithsSuccess
            ? (state as AhadithsSuccess).allAhadith
            : <Hadith>[];

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
    required List<Hadith> existingAhadith,
  }) async {
    final result = await _chapterAhadithsRepo.getAhadith(
      bookSlug: bookSlug,
      chapterId: chapterId,
      page: page,
      paginate: paginate,
    );

    result.fold(
      (error) {
        _isLoadingMore = false;
        if (existingAhadith.isEmpty) {
          emit(AhadithsFailure(error.getAllErrorMessages()));
        } else {
          // Keep existing data on pagination error
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
      (response) {
        final newAhadith = response.hadiths?.data ?? [];
        final totalPages = response.hadiths?.last_page ?? 1;
        final total = response.hadiths?.total ?? 0;

        if (newAhadith.isEmpty) {
          _hasMore = false;
        } else {
          _hasMore = page < totalPages;
        }

        final merged = _chapterAhadithsRepo.mergeAhadith(
          existingAhadith,
          newAhadith,
        );
        _currentPage = page;
        _isLoadingMore = false;

        // Update cache
        _chapterAhadithsRepo.cacheAhadith(
          bookSlug: bookSlug,
          chapterId: chapterId,
          ahadith: merged,
          lastPage: _currentPage,
          totalCount: total,
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
    );
  }

  Future<void> _loadLocalBooks({
    required String bookSlug,
    required int chapterId,
    required bool isArbainBooks,
  }) async {
    if (isArbainBooks) {
      final result = await _chapterAhadithsRepo.getThreeAhadith(
        bookSlug: bookSlug,
        chapterId: chapterId,
      );

      result.fold(
        (l) => emit(AhadithsFailure(l.getAllErrorMessages())),
        (r) => emit(LocalAhadithsSuccess(hadiths: r.hadiths?.data ?? [])),
      );
    } else {
      final result = await _chapterAhadithsRepo.getLocalAhadith(
        bookSlug: bookSlug,
        chapterId: chapterId,
      );

      result.fold(
        (l) => emit(AhadithsFailure(l.getAllErrorMessages())),
        (r) => emit(LocalAhadithsSuccess(hadiths: r.hadiths?.data ?? [])),
      );
    }
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
    }
  }
}
