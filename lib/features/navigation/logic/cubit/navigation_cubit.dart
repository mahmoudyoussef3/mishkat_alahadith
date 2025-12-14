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
    emit(NavigationLoading());
    final result = await _navigationRepo.navigationHadith(
      hadithNumber,
      bookSlug,
      chapterNumber,
    );

    result.fold(
      (l) => emit(
        NavigationFailure(l.getAllErrorMessages()),
      ),
      (r) => emit(NavigationSuccess(r)),
    );
  }


}
