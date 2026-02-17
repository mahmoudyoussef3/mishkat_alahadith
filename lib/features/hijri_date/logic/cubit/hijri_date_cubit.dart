import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/usecases/get_hijri_date_usecase.dart';
import 'package:mishkat_almasabih/features/hijri_date/domain/repositories/hijri_repository.dart';
import 'package:mishkat_almasabih/features/hijri_date/logic/states/hijri_date_state.dart';

/// Cubit for managing Hijri date with remote offset.
///
/// This example demonstrates how to use the Hijri date system in your UI.
///
/// Usage in your screen:
/// ```dart
/// BlocBuilder<HijriDateCubit, HijriDateState>(
///   builder: (context, state) {
///     if (state is HijriDateLoaded) {
///       return Text('${state.hijriDate.hDay} ${state.hijriDate.getLongMonthName()} ${state.hijriDate.hYear}');
///     }
///     return CircularProgressIndicator();
///   },
/// )
/// ```
///
/// Or use it directly without Cubit:
/// ```dart
/// final hijriDate = getIt<GetHijriDateUseCase>().call();
/// ```
class HijriDateCubit extends Cubit<HijriDateState> {
  final GetHijriDateUseCase _getHijriDateUseCase;
  final HijriRepository _repository;

  HijriDateCubit({
    required GetHijriDateUseCase getHijriDateUseCase,
    required HijriRepository repository,
  }) : _getHijriDateUseCase = getHijriDateUseCase,
       _repository = repository,
       super(HijriDateInitial());

  /// Loads the current Hijri date with applied offset.
  ///
  /// This method:
  /// 1. Gets the adjusted Hijri date from the use case
  /// 2. Gets the current offset value for display/debugging
  /// 3. Emits loaded state with both values
  ///
  /// Safe to call multiple times - always returns current adjusted date.
  /// Never throws - any errors are caught and emitted as error state.
  Future<void> loadHijriDate() async {
    try {
      emit(HijriDateLoading());

      // Get the adjusted Hijri date
      final hijriDate = _getHijriDateUseCase.call();

      // Get the offset value for informational purposes
      final offset = _repository.getHijriDateOffset();

      emit(HijriDateLoaded(hijriDate: hijriDate, appliedOffset: offset));
    } catch (e) {
      emit(HijriDateError(message: 'Failed to load Hijri date: $e'));
    }
  }

  /// Refreshes the Hijri date by reloading from Remote Config.
  ///
  /// Use this when:
  /// - User manually pulls to refresh
  /// - App returns from background after significant time
  /// - You want to check for offset updates
  ///
  /// This will fetch latest config from Firebase and recalculate date.
  Future<void> refreshHijriDate() async {
    try {
      emit(HijriDateLoading());

      // Re-fetch Remote Config to get latest offset
      await _repository.initializeRemoteConfig();

      // Get the updated Hijri date with new offset
      final hijriDate = _getHijriDateUseCase.call();
      final offset = _repository.getHijriDateOffset();

      emit(HijriDateLoaded(hijriDate: hijriDate, appliedOffset: offset));
    } catch (e) {
      emit(HijriDateError(message: 'Failed to refresh Hijri date: $e'));
    }
  }
}
