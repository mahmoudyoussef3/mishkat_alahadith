import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/navigation/domain/entities/hadith_navigation.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_local_hadith_navigation_use_case.dart';

part 'local_hadith_navigation_state.dart';

class LocalHadithNavigationCubit extends Cubit<LocalHadithNavigationState> {
  final GetLocalHadithNavigationUseCase _getLocalNavigation;
  LocalHadithNavigationCubit(this._getLocalNavigation)
    : super(LocalHadithNavigationInitial());

  Future<void> emitLocalNavigation(String hadithNumber, String bookSlug) async {
    emit(LocalHadithNavigationLoading());

    final result = await _getLocalNavigation(
      hadithNumber: hadithNumber,
      bookSlug: bookSlug,
    );

    result.when(
      success: (navigation) => emit(LocalHadithNavigationSuccess(navigation)),
      failure: (failure) => emit(LocalHadithNavigationFailure(failure.message)),
    );
  }
}
