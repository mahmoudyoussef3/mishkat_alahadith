import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/fetch_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_saved_daily_hadith_use_case.dart';

part 'daily_hadith_state.dart';

class DailyHadithCubit extends Cubit<DailyHadithState> {
  static const String _defaultHadithId = '65060';
  static const String _loadFailedMessage = 'تعذر تحميل حديث اليوم';

  final GetSavedDailyHadithUseCase _getSavedHadith;
  final FetchDailyHadithUseCase _fetchHadith;

  DailyHadithCubit(this._getSavedHadith, this._fetchHadith)
    : super(DailyHadithInitial());

  Future<void> load() async {
    final cached = await _getSavedHadith();

    if (cached != null) {
      emit(DailyHadithSuccess(cached));
    } else {
      emit(DailyHadithLoading());
      await _fetchFromServer(_defaultHadithId);
    }
  }

  Future<void> fetchById(String id) async {
    emit(DailyHadithLoading());
    await _fetchFromServer(id);
  }

  Future<void> _fetchFromServer(String id) async {
    final result = await _fetchHadith(id);
    result.when(
      success: (hadith) => emit(DailyHadithSuccess(hadith)),
      failure: (failure) => emit(
        DailyHadithFailure(
          failure is NetworkFailure ? failure.message : _loadFailedMessage,
        ),
      ),
    );
  }
}
