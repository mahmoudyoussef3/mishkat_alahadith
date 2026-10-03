import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_cached_library_statistics_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_statistics_use_case.dart';

part 'get_library_statistics_state.dart';

class GetLibraryStatisticsCubit extends Cubit<GetLibraryStatisticsState> {
  final GetCachedLibraryStatisticsUseCase _getCachedStatistics;
  final GetLibraryStatisticsUseCase _getStatistics;
  GetLibraryStatisticsCubit(this._getCachedStatistics, this._getStatistics)
    : super(GetLibraryStatisticsInitial());

  Future<void> emitGetStatisticsCubit() async {
    final cached = await _getCachedStatistics();

    if (cached != null) {
      emit(
        GetLivraryStatisticsSuccess(
          statistics: cached,
          isFromCache: true,
          isRefreshing: true,
        ),
      );

      _backgroundRefresh();
    } else {
      emit(GetLivraryStatisticsLoading());
      final response = await _getStatistics();
      response.when(
        success: (data) => emit(GetLivraryStatisticsSuccess(statistics: data)),
        failure: (failure) => emit(GetLivraryStatisticsError(failure.message)),
      );
    }
  }

  Future<void> _backgroundRefresh() async {
    final response = await _getStatistics();
    response.when(
      success: (data) {
        emit(
          GetLivraryStatisticsSuccess(
            statistics: data,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
      failure: (_) {
        if (state is GetLivraryStatisticsSuccess) {
          emit(
            (state as GetLivraryStatisticsSuccess).copyWith(
              isRefreshing: false,
            ),
          );
        }
      },
    );
  }
}
