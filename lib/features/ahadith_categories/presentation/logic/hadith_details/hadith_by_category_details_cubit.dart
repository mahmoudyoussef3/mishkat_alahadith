import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_cached_hadith_details_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/usecases/get_hadith_details_use_case.dart';

part 'hadith_by_category_details_state.dart';

class HadithByCategoryDetailsCubit extends Cubit<HadithByCategoryDetailsState> {
  final GetCachedHadithDetailsUseCase _getCachedDetails;
  final GetHadithDetailsUseCase _getDetails;

  HadithByCategoryDetailsCubit(this._getCachedDetails, this._getDetails)
    : super(HadithByCategoryDetailsInitial());

  Future<void> fetchById(String id) async {
    final cached = await _getCachedDetails(id);

    if (cached != null) {
      emit(HadithByCategoryDetailsLoaded(cached));
      return;
    }

    emit(HadithByCategoryDetailsLoading());
    final result = await _getDetails(id);
    result.when(
      success: (hadith) => emit(HadithByCategoryDetailsLoaded(hadith)),
      failure:
          (failure) => emit(
            HadithByCategoryDetailsError(
              failure is NetworkFailure
                  ? failure.message
                  : 'تعذر تحميل تفاصيل الحديث',
            ),
          ),
    );
  }
}
