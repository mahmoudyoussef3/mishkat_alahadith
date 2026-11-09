import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_ayah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';

part 'ayah_commentary_state.dart';

/// The tafsir and translation of the ayah in the ayah sheet. Loaded apart
/// from the ayah itself, which is on the device: the commentary comes from
/// the network and may be slow, or not come at all.
class AyahCommentaryCubit extends Cubit<AyahCommentaryState> {
  final GetCommentarySettingsUseCase _getSettings;
  final SaveCommentarySettingsUseCase _saveSettings;
  final GetAyahCommentaryUseCase _getCommentary;

  CommentarySettings? _settings;
  int? _ayahId;

  /// Counts loads, so only the latest one is shown.
  int _loads = 0;

  AyahCommentaryCubit(
    this._getSettings,
    this._saveSettings,
    this._getCommentary,
  ) : super(const AyahCommentaryLoading(CommentarySettings.defaults));

  Future<void> load(int ayahId) async {
    _ayahId = ayahId;
    final load = ++_loads;
    final settings =
        _settings ??= switch (await _getSettings()) {
          ApiSuccess(:final data) => data,
          // The default tafsir stands in for settings that cannot be read.
          ApiFailure() => CommentarySettings.defaults,
        };
    if (isClosed || load != _loads) return;
    emit(AyahCommentaryLoading(settings));
    final result = await _getCommentary(ayahId, settings);
    if (isClosed || load != _loads) return;
    emit(switch (result) {
      ApiSuccess(:final data) => AyahCommentaryLoaded(settings, data),
      ApiFailure(:final failure) => AyahCommentaryFailure(
        settings,
        failure.message,
      ),
    });
  }

  Future<void> retry() async {
    final ayahId = _ayahId;
    if (ayahId != null) await load(ayahId);
  }

  /// Shows [edition] from now on, here and with every ayah.
  Future<bool> setTafsir(QuranEdition edition) =>
      _change((s) => s.copyWith(tafsirId: edition.identifier));

  /// Shows [edition] alongside the tafsir, or no translation when null.
  Future<bool> setTranslation(QuranEdition? edition) =>
      _change((s) => s.copyWith(translationId: () => edition?.identifier));

  Future<bool> _change(
    CommentarySettings Function(CommentarySettings) change,
  ) async {
    final current = _settings ?? state.settings;
    final updated = change(current);
    if (updated == current) return true;
    _settings = updated;
    final saved = await _saveSettings(updated);
    await retry();
    return saved is ApiSuccess;
  }
}
