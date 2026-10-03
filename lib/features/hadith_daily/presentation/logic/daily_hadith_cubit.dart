import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

part 'daily_hadith_state.dart';

class DailyHadithCubit extends Cubit<DailyHadithState> {
  final SaveHadithDailyRepo _repo;
  final NetworkInfo _networkInfo;

  DailyHadithCubit(this._repo, this._networkInfo) : super(DailyHadithInitial());

  /// Loads hadith from local cache; if missing, fetches a default one and saves it.
  Future<void> load() async {
    final hasInternet = await _networkInfo.isConnected;
    final cached = await _repo.getHadith();
    
    if (hasInternet) {
      if (cached != null) {
        emit(DailyHadithSuccess(cached));
        // Optional background refresh could go here
      } else {
        emit(DailyHadithLoading());
        _fetchFromServer('65060');
      }
    } else {
      if (cached != null) {
        emit(DailyHadithSuccess(cached));
      } else {
        emit(DailyHadithFailure('لا يوجد اتصال بالإنترنت'));
      }
    }
  }

  Future<void> fetchById(String id) async {
    final hasInternet = await _networkInfo.isConnected;
    if (!hasInternet) {
      emit(DailyHadithFailure('لا يوجد اتصال بالإنترنت'));
      return;
    }
    emit(DailyHadithLoading());
    _fetchFromServer(id);
  }

  Future<void> _fetchFromServer(String id) async {
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
