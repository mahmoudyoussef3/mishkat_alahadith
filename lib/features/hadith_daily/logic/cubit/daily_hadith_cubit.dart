import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';

part 'daily_hadith_state.dart';

class DailyHadithCubit extends Cubit<DailyHadithState> {
  final SaveHadithDailyRepo _repo;

  DailyHadithCubit(this._repo) : super(DailyHadithInitial());

  /// Loads hadith from local cache; if missing, fetches a default one and saves it.
  Future<void> load() async {
    emit(DailyHadithLoading());
    try {
      final cached = await _repo.getHadith();
      if (cached != null) {
        emit(DailyHadithSuccess(cached));
        return;
      }
      final fetched = await _repo.fetchHadith('65060');
      if (fetched != null) {
        emit(DailyHadithSuccess(fetched));
      } else {
        emit(DailyHadithFailure('تعذر تحميل حديث اليوم'));
      }
    } catch (e) {
      emit(DailyHadithFailure('تعذر تحميل حديث اليوم'));
    }
  }

  Future<void> fetchById(String id) async {
    emit(DailyHadithLoading());
    try {
      final fetched = await _repo.fetchHadith(id);
      if (fetched != null) {
        emit(DailyHadithSuccess(fetched));
      } else {
        emit(DailyHadithFailure('تعذر تحميل حديث اليوم'));
      }
    } catch (e) {
      emit(DailyHadithFailure('تعذر تحميل حديث اليوم'));
    }
  }
}
