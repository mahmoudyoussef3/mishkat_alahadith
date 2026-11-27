import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surah_commentary_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';

part 'surah_tafsir_state.dart';

/// A surah's tafsir read straight through, a page of ayahs at a time.
class SurahTafsirCubit extends Cubit<SurahTafsirState> {
  final GetCommentarySettingsUseCase _getSettings;
  final SaveCommentarySettingsUseCase _saveSettings;
  final GetSurahCommentaryUseCase _getPage;

  CommentarySettings? _settings;
  int? _surahNumber;
  int _startAyah = 1;

  /// Counts fresh loads; a page that arrives for an older one is dropped.
  int _loads = 0;

  SurahTafsirCubit(this._getSettings, this._saveSettings, this._getPage)
    : super(const SurahTafsirLoading(CommentarySettings.defaults));

  /// [surahNumber] from ayah [startAyah] on.
  Future<void> load(int surahNumber, {int startAyah = 1}) async {
    _surahNumber = surahNumber;
    _startAyah = startAyah < 1 ? 1 : startAyah;
    final load = ++_loads;
    final settings =
        _settings ??= switch (await _getSettings()) {
          ApiSuccess(:final data) => data,
          ApiFailure() => CommentarySettings.defaults,
        };
    if (isClosed || load != _loads) return;
    emit(SurahTafsirLoading(settings));
    final result = await _getPage(
      surahNumber,
      settings,
      offset: _startAyah - 1,
    );
    if (isClosed || load != _loads) return;
    emit(switch (result) {
      ApiSuccess(data: final page) => SurahTafsirLoaded(
        settings,
        surah: page.surah,
        ayahs: page.ayahs,
        startAyah: _startAyah,
        nextOffset: page.nextOffset,
        hasMore: page.hasMore,
      ),
      ApiFailure(:final failure) => SurahTafsirFailure(
        settings,
        failure.message,
      ),
    });
  }

  /// Loads the next page, once the reader nears the end of this one.
  Future<void> loadMore() async {
    final current = state;
    if (current is! SurahTafsirLoaded ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final load = _loads;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    final result = await _getPage(
      current.surah.number,
      current.settings,
      offset: current.nextOffset,
    );
    final latest = state;
    if (isClosed || load != _loads || latest is! SurahTafsirLoaded) return;
    emit(switch (result) {
      ApiSuccess(data: final page) => latest.copyWith(
        ayahs: [...latest.ayahs, ...page.ayahs],
        nextOffset: page.nextOffset,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ),
      ApiFailure(:final failure) => latest.copyWith(
        isLoadingMore: false,
        loadMoreFailure: () => failure.message,
      ),
    });
  }

  /// Starts again from the surah's first ayah.
  Future<void> showFromStart() async {
    final surah = _surahNumber;
    if (surah != null) await load(surah);
  }

  Future<void> retry() async {
    final surah = _surahNumber;
    if (surah != null) await load(surah, startAyah: _startAyah);
  }

  Future<bool> setTafsir(QuranEdition edition) =>
      _change((s) => s.copyWith(tafsirId: edition.identifier));

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
