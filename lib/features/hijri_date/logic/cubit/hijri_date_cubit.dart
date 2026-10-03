import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';

class HijriDateCubit extends Cubit<HijriDateState> {
  final GetHijriDateUseCase _getHijriDateUseCase;
  final HijriRepository _repository;

  HijriDateCubit({
    required GetHijriDateUseCase getHijriDateUseCase,
    required HijriRepository repository,
  }) : _getHijriDateUseCase = getHijriDateUseCase,
       _repository = repository,
       super(HijriDateInitial());

  Future<void> loadHijriDate() async {
    try {
      emit(HijriDateLoading());

      final hijriDate = _getHijriDateUseCase.call();

      final offset = _repository.getHijriDateOffset();

      emit(HijriDateLoaded(hijriDate: hijriDate, appliedOffset: offset));
    } catch (e) {
      emit(HijriDateError(message: 'Failed to load Hijri date: $e'));
    }
  }

  Future<void> refreshHijriDate() async {
    try {
      emit(HijriDateLoading());

      await _repository.initializeRemoteConfig();

      final hijriDate = _getHijriDateUseCase.call();
      final offset = _repository.getHijriDateOffset();

      emit(HijriDateLoaded(hijriDate: hijriDate, appliedOffset: offset));
    } catch (e) {
      emit(HijriDateError(message: 'Failed to refresh Hijri date: $e'));
    }
  }
}
