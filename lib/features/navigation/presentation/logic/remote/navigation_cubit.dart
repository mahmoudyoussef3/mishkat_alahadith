import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/local_hadith_navigation_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/navigation_hadith_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/repos/navigation_repo.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  final NavigationRepo _navigationRepo;
  NavigationCubit(this._navigationRepo) : super(NavigationInitial());

  Future<void> emitNavigationStates(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
  ) async {
    // Try cache first
    final cached = await _navigationRepo.getCachedNavigation(
      bookSlug,
      int.tryParse(chapterNumber) ?? 0,
      hadithNumber,
    );

    if (cached != null) {
      // Emit cached data immediately
      emit(NavigationSuccess(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(hadithNumber, bookSlug, chapterNumber, cached);
    } else {
      // No cache, fetch from API
      emit(NavigationLoading());
      final result = await _navigationRepo.navigationHadith(
        hadithNumber,
        bookSlug,
        chapterNumber,
      );
      result.fold(
        (l) => emit(NavigationFailure(l.getAllErrorMessages())),
        (r) => emit(NavigationSuccess(r)),
      );
    }
  }

  Future<void> _backgroundRefresh(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
    NavigationHadithResponse cached,
  ) async {
    final result = await _navigationRepo.navigationHadith(
      hadithNumber,
      bookSlug,
      chapterNumber,
    );
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is NavigationSuccess) {
          emit((state as NavigationSuccess).copyWith(isRefreshing: false));
        }
      },
      (response) {
        emit(
          NavigationSuccess(response, isFromCache: false, isRefreshing: false),
        );
      },
    );
  }
}
