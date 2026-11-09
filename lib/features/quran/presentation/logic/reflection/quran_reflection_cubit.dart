import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_reflection_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';

part 'quran_reflection_state.dart';

/// An ayah picked at random, with its tafsir, on the Quran home.
class QuranReflectionCubit extends Cubit<QuranReflectionState> {
  final GetCommentarySettingsUseCase _getSettings;
  final GetReflectionAyahUseCase _getReflection;

  /// Counts loads, so only the latest one is shown.
  int _loads = 0;

  QuranReflectionCubit(this._getSettings, this._getReflection)
    : super(const QuranReflectionLoading());

  /// Picks another ayah. The one shown stays while the next loads.
  Future<void> load() async {
    final load = ++_loads;
    final current = state;
    emit(
      QuranReflectionLoading(
        previous: switch (current) {
          QuranReflectionLoaded(:final ayah) => ayah,
          QuranReflectionLoading(:final previous) => previous,
          QuranReflectionFailure() => null,
        },
      ),
    );
    final settings = switch (await _getSettings()) {
      ApiSuccess(:final data) => data,
      ApiFailure() => CommentarySettings.defaults,
    };
    final result = await _getReflection(settings);
    if (isClosed || load != _loads) return;
    emit(switch (result) {
      ApiSuccess(:final data) => QuranReflectionLoaded(data),
      ApiFailure(:final failure) => QuranReflectionFailure(failure.message),
    });
  }
}
