

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repositories/hadith_by_category_details_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/models/new_daily_hadith_model.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

part 'hadith_by_category_details_state.dart';

class HadithByCategoryDetailsCubit extends Cubit<HadithByCategoryDetailsState> {
  final HadithByCategoryDetailsRepo _repo;
  final NetworkInfo _networkInfo;

  HadithByCategoryDetailsCubit(this._repo, this._networkInfo) : super(HadithByCategoryDetailsInitial());

  Future<void> fetchById(String id) async {
    final cached = await _repo.getCachedHadith(id);

    if (cached != null) {
      emit(HadithByCategoryDetailsLoaded(cached));
      return;
    }

    final hasInternet = await _networkInfo.isConnected;
    
    if (hasInternet) {
      emit(HadithByCategoryDetailsLoading());
      _fetchFromServer(id);
    } else {
      emit(HadithByCategoryDetailsError('لا يوجد اتصال بالإنترنت'));
    }
  }

  Future<void> _fetchFromServer(String id) async {
    try {
      final fetched = await _repo.fetchHadith(id);
      if (fetched != null) {
        emit(HadithByCategoryDetailsLoaded(fetched));
      } else {
        emit(HadithByCategoryDetailsError('تعذر تحميل تفاصيل الحديث'));
      }
    } catch (e) {
      emit(HadithByCategoryDetailsError('حدث خطأ أثناء تحميل تفاصيل الحديث'));
    }
  }
}
