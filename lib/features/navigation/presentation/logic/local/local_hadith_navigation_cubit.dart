import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/local_hadith_navigation_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/repos/navigation_repo.dart';

part 'local_hadith_navigation_state.dart';

class LocalHadithNavigationCubit extends Cubit<LocalHadithNavigationState> {
  final NavigationRepo _navigationRepo;
  LocalHadithNavigationCubit(this._navigationRepo) : super(LocalHadithNavigationInitial());

  Future<void> emitLocalNavigation(String hadithNumber, String bookSlug) async {
    emit(LocalHadithNavigationLoading());

    final result = await _navigationRepo.localNavigation(
      hadithNumber,
      bookSlug,
    );

    result.fold(
      (l) => emit(
        LocalHadithNavigationFailure(l.getAllErrorMessages()),
      ),
      (r) => emit(LocalHadithNavigationSuccess(r)),
    );
  }
}
