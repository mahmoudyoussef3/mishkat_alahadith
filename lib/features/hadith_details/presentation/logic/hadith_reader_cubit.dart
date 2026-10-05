import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/navigation/domain/entities/hadith_navigation.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_cached_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_local_hadith_navigation_use_case.dart';

part 'hadith_reader_state.dart';

/// The hadith being read and its neighbours in the chapter, so the reader
/// can step backwards and forwards without leaving the screen.
class HadithReaderCubit extends Cubit<HadithReaderState> {
  final GetCachedHadithNavigationUseCase _getCachedNavigation;
  final GetHadithNavigationUseCase _getNavigation;
  final GetLocalHadithNavigationUseCase _getLocalNavigation;

  HadithReaderCubit(
    this._getCachedNavigation,
    this._getNavigation,
    this._getLocalNavigation,
  ) : super(const HadithReaderState(hadithId: '', text: ''));

  String _bookSlug = '';
  String _chapterNumber = '';
  bool _isLocal = false;

  /// Shows [text] and, when [withNavigation], finds its neighbours.
  Future<void> start({
    required String hadithId,
    required String text,
    required String bookSlug,
    required String chapterNumber,
    required bool isLocal,
    bool withNavigation = true,
  }) async {
    _bookSlug = bookSlug;
    _chapterNumber = chapterNumber;
    _isLocal = isLocal;
    final canNavigate = withNavigation && hadithId.isNotEmpty;
    emit(HadithReaderState(hadithId: hadithId, text: text, isLoading: canNavigate));
    if (canNavigate) await _loadNeighbours();
  }

  Future<void> next() => _moveTo(state.next);

  Future<void> previous() => _moveTo(state.previous);

  /// Tries again after the neighbours failed to load.
  Future<void> retry() async {
    if (state.isLoading || state.hadithId.isEmpty) return;
    emit(state.copyWith(isLoading: true, failed: false));
    await _loadNeighbours();
  }

  Future<void> _moveTo(NavigationHadithRef? target) async {
    final id = target?.id;
    if (id == null || id.isEmpty || state.isLoading) return;
    emit(
      HadithReaderState(
        hadithId: id,
        text: target?.title ?? '',
        chapterTotal: state.chapterTotal,
        isLoading: true,
      ),
    );
    await _loadNeighbours();
  }

  Future<void> _loadNeighbours() async {
    final hadithId = state.hadithId;
    final result = await _fetch(hadithId);
    // A newer step may have started while this one was loading.
    if (isClosed || state.hadithId != hadithId) return;

    switch (result) {
      case ApiSuccess(data: final navigation):
        emit(
          state.copyWith(
            previous: navigation.prevHadith,
            next: navigation.nextHadith,
            chapterTotal: navigation.totalHadiths,
            isLoading: false,
          ),
        );
      case ApiFailure():
        emit(state.copyWith(isLoading: false, failed: true));
    }
  }

  Future<ApiResult<HadithNavigation>> _fetch(String hadithId) async {
    if (_isLocal) {
      return _getLocalNavigation(hadithNumber: hadithId, bookSlug: _bookSlug);
    }
    final cached = await _getCachedNavigation(
      hadithNumber: hadithId,
      bookSlug: _bookSlug,
      chapterNumber: _chapterNumber,
    );
    if (cached != null) return ApiResult.success(cached);
    return _getNavigation(
      hadithNumber: hadithId,
      bookSlug: _bookSlug,
      chapterNumber: _chapterNumber,
    );
  }
}
