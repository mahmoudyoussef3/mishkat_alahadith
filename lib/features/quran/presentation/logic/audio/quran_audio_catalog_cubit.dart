import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';

sealed class QuranAudioCatalogState {
  const QuranAudioCatalogState();
}

final class QuranAudioCatalogLoading extends QuranAudioCatalogState {
  const QuranAudioCatalogLoading();
}

final class QuranAudioCatalogFailure extends QuranAudioCatalogState {
  const QuranAudioCatalogFailure(this.message);

  final String message;
}

final class QuranAudioCatalogReady extends QuranAudioCatalogState {
  const QuranAudioCatalogReady(this.surahs, this.visible, this.query);

  final List<QuranSurah> surahs;
  final List<QuranSurah> visible;
  final String query;
}

class QuranAudioCatalogCubit extends Cubit<QuranAudioCatalogState> {
  QuranAudioCatalogCubit(this._getSurahs, this._filterSurahs)
    : super(const QuranAudioCatalogLoading());

  final GetSurahsUseCase _getSurahs;
  final FilterSurahsUseCase _filterSurahs;

  Future<void> load() async {
    emit(const QuranAudioCatalogLoading());
    final result = await _getSurahs();
    if (isClosed) return;
    emit(switch (result) {
      ApiSuccess(:final data) => QuranAudioCatalogReady(data, data, ''),
      ApiFailure(:final failure) => QuranAudioCatalogFailure(failure.message),
    });
  }

  void filter(String query) {
    if (state case QuranAudioCatalogReady(:final surahs)) {
      emit(QuranAudioCatalogReady(surahs, _filterSurahs(surahs, query), query));
    }
  }
}
