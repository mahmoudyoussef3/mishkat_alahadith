import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_ayah_details_use_case.dart';

part 'ayah_details_state.dart';

class AyahDetailsCubit extends Cubit<AyahDetailsState> {
  final GetAyahDetailsUseCase _getAyahDetails;

  AyahDetailsCubit(this._getAyahDetails) : super(const AyahDetailsLoading());

  Future<void> load(int ayahId, {required bool includeNaturalMadd}) async {
    emit(const AyahDetailsLoading());
    final result = await _getAyahDetails(
      ayahId,
      includeNaturalMadd: includeNaturalMadd,
    );
    if (isClosed) return;
    emit(switch (result) {
      ApiSuccess(:final data) => AyahDetailsLoaded(data),
      ApiFailure(:final failure) => AyahDetailsFailure(failure.message),
    });
  }
}
