import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/home/data/models/library_statistics_model.dart';
import 'package:mishkat_almasabih/features/home/data/repos/get_library_statistics_repo.dart';

part 'get_library_statistics_state.dart';

class GetLibraryStatisticsCubit extends Cubit<GetLibraryStatisticsState> {
  GetLibraryStatisticsRepo _getLibraryStatisticsRepo;
  GetLibraryStatisticsCubit(this._getLibraryStatisticsRepo)
    : super(GetLibraryStatisticsInitial());

  Future<void> emitGetStatisticsCubit() async {
    // Try cache first
    final cached = await _getLibraryStatisticsRepo.getCachedStatistics();

    if (cached != null) {
      // Emit cached data immediately
      emit(
        GetLivraryStatisticsSuccess(
          statisticsResponse: cached,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      // Background refresh
      _backgroundRefresh(cached);
    } else {
      // No cache, fetch from API
      emit(GetLivraryStatisticsLoading());
      final response = await _getLibraryStatisticsRepo.getLibraryStatistics();
      response.fold(
        (error) => emit(GetLivraryStatisticsError(error.getAllErrorMessages())),
        (data) => emit(GetLivraryStatisticsSuccess(statisticsResponse: data)),
      );
    }
  }

  Future<void> _backgroundRefresh(StatisticsResponse cached) async {
    final response = await _getLibraryStatisticsRepo.getLibraryStatistics();
    response.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is GetLivraryStatisticsSuccess) {
          emit(
            (state as GetLivraryStatisticsSuccess).copyWith(
              isRefreshing: false,
            ),
          );
        }
      },
      (data) {
        emit(
          GetLivraryStatisticsSuccess(
            statisticsResponse: data,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
