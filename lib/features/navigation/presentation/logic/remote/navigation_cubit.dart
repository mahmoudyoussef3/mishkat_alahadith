import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/navigation/domain/entities/hadith_navigation.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_cached_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_hadith_navigation_use_case.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  final GetCachedHadithNavigationUseCase _getCachedNavigation;
  final GetHadithNavigationUseCase _getNavigation;
  NavigationCubit(this._getCachedNavigation, this._getNavigation)
    : super(NavigationInitial());

  Future<void> emitNavigationStates(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
  ) async {
    final cached = await _getCachedNavigation(
      hadithNumber: hadithNumber,
      bookSlug: bookSlug,
      chapterNumber: chapterNumber,
    );

    if (cached != null) {
      emit(NavigationSuccess(cached, isFromCache: true, isRefreshing: true));

      _backgroundRefresh(hadithNumber, bookSlug, chapterNumber);
    } else {
      emit(NavigationLoading());
      final result = await _getNavigation(
        hadithNumber: hadithNumber,
        bookSlug: bookSlug,
        chapterNumber: chapterNumber,
      );
      result.when(
        success: (navigation) => emit(NavigationSuccess(navigation)),
        failure: (failure) => emit(NavigationFailure(failure.message)),
      );
    }
  }

  Future<void> _backgroundRefresh(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
  ) async {
    final result = await _getNavigation(
      hadithNumber: hadithNumber,
      bookSlug: bookSlug,
      chapterNumber: chapterNumber,
    );
    result.when(
      success: (navigation) {
        emit(
          NavigationSuccess(
            navigation,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
      failure: (_) {
        if (state is NavigationSuccess) {
          emit((state as NavigationSuccess).copyWith(isRefreshing: false));
        }
      },
    );
  }
}
