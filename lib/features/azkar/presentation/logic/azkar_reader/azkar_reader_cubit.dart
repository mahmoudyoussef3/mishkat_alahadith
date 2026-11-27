import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/zikr.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_catalog_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_settings_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_favorite_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_today_azkar_progress_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/reset_azkar_category_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/save_azkar_settings_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/set_zikr_count_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/toggle_favorite_azkar_use_case.dart';

part 'azkar_reader_state.dart';

/// One chapter being read and counted. Counts show at once and are saved in
/// the background, one after another.
class AzkarReaderCubit extends Cubit<AzkarReaderState> {
  static const String notFoundMessage = 'تعذر العثور على هذا الباب';

  final GetAzkarCatalogUseCase _getCatalog;
  final GetTodayAzkarProgressUseCase _getProgress;
  final SetZikrCountUseCase _setCount;
  final ResetAzkarCategoryUseCase _resetCategory;
  final GetFavoriteAzkarUseCase _getFavorites;
  final ToggleFavoriteAzkarUseCase _toggleFavorite;
  final GetAzkarSettingsUseCase _getSettings;
  final SaveAzkarSettingsUseCase _saveSettings;

  var _focusSerial = 0;

  AzkarReaderCubit(
    this._getCatalog,
    this._getProgress,
    this._setCount,
    this._resetCategory,
    this._getFavorites,
    this._toggleFavorite,
    this._getSettings,
    this._saveSettings,
  ) : super(const AzkarReaderLoading());

  /// Opens at [zikrId] when given, otherwise where the reader left off
  /// today.
  Future<void> load(int categoryId, {int? zikrId}) async {
    emit(const AzkarReaderLoading());
    final settings = switch (await _getSettings()) {
      ApiSuccess(:final data) => data,
      ApiFailure() => AzkarSettings.defaults,
    };
    final catalog = await _getCatalog(settings.translation);
    if (isClosed) return;

    switch (catalog) {
      case ApiFailure(:final failure):
        emit(AzkarReaderFailure(failure.message));
      case ApiSuccess(data: final categories):
        final category =
            categories.where((c) => c.id == categoryId).firstOrNull;
        if (category == null) {
          emit(const AzkarReaderFailure(notFoundMessage));
          return;
        }
        final (progress, favorites) =
            await (_getProgress(), _getFavorites()).wait;
        if (isClosed) return;

        final loaded = AzkarReaderLoaded(
          category: category,
          counts: switch (progress) {
            ApiSuccess(:final data) => data.countsFor(categoryId),
            ApiFailure() => const {},
          },
          isFavorite: switch (favorites) {
            ApiSuccess(:final data) => data.contains(categoryId),
            ApiFailure() => false,
          },
          settings: settings,
          day: switch (progress) {
            ApiSuccess(:final data) => data.day,
            ApiFailure() => null,
          },
        );
        final resumeAt =
            zikrId != null && category.zikrById(zikrId) != null
                ? zikrId
                : loaded.progress.isStarted
                ? loaded.nextPendingAfter(null)
                : null;
        emit(loaded.copyWith(focus: () => _focusOn(resumeAt)));
    }
  }

  /// Counts one repetition of the zikr.
  ZikrCountOutcome count(int zikrId) {
    final current = state;
    if (current is! AzkarReaderLoaded) return ZikrCountOutcome.ignored;
    final zikr = current.category.zikrById(zikrId);
    if (zikr == null || current.isDone(zikr)) return ZikrCountOutcome.ignored;

    final said = current.countOf(zikrId) + 1;
    final updated = current.copyWith(counts: {...current.counts, zikrId: said});
    final finished = said == zikr.count;
    final next =
        finished && current.settings.autoAdvance
            ? updated.nextPendingAfter(zikrId)
            : null;
    emit(updated.copyWith(focus: next == null ? null : () => _focusOn(next)));
    unawaited(_save(zikrId, said));

    if (!finished) return ZikrCountOutcome.counted;
    return updated.progress.isComplete
        ? ZikrCountOutcome.categoryCompleted
        : ZikrCountOutcome.zikrCompleted;
  }

  /// Starts one zikr's count again.
  Future<void> resetZikr(int zikrId) async {
    final current = state;
    if (current is! AzkarReaderLoaded || current.countOf(zikrId) == 0) return;
    emit(current.copyWith(counts: {...current.counts}..remove(zikrId)));
    await _save(zikrId, 0);
  }

  /// Starts the whole chapter again from its first zikr.
  Future<void> resetAll() async {
    final current = state;
    if (current is! AzkarReaderLoaded) return;
    emit(
      current.copyWith(
        counts: const {},
        focus: () => _focusOn(current.category.azkar.firstOrNull?.id),
      ),
    );
    switch (await _resetCategory(current.category.id)) {
      case ApiFailure():
        _reportFailedSave();
      case ApiSuccess(:final data):
        _adoptNewDay(data);
    }
  }

  /// Starts afresh when a new day has begun since the counts were loaded,
  /// as when the app comes back to an azkar left open overnight.
  Future<void> refreshProgress() async {
    if (state is! AzkarReaderLoaded) return;
    if (await _getProgress() case ApiSuccess(:final data)) _adoptNewDay(data);
  }

  /// Null when the change could not be saved; otherwise whether the chapter
  /// is now a favourite.
  Future<bool?> toggleFavorite() async {
    final current = state;
    if (current is! AzkarReaderLoaded) return null;
    final result = await _toggleFavorite(current.category.id);
    final latest = state;
    if (isClosed || latest is! AzkarReaderLoaded) return null;
    switch (result) {
      case ApiFailure():
        return null;
      case ApiSuccess(:final data):
        emit(latest.copyWith(isFavorite: data));
        return data;
    }
  }

  /// Applies [settings] at once and saves them; a new translation is loaded
  /// in under the same counts.
  Future<void> updateSettings(AzkarSettings settings) async {
    final current = state;
    if (current is! AzkarReaderLoaded || current.settings == settings) return;
    emit(current.copyWith(settings: settings));
    if (await _saveSettings(settings) is ApiFailure) _reportFailedSave();

    if (settings.translation == current.settings.translation) return;
    final catalog = await _getCatalog(settings.translation);
    final latest = state;
    if (isClosed || latest is! AzkarReaderLoaded) return;
    // A quicker later choice may already be showing.
    if (latest.settings.translation != settings.translation) return;
    if (catalog case ApiSuccess(data: final categories)) {
      final category =
          categories.where((c) => c.id == latest.category.id).firstOrNull;
      if (category != null) emit(latest.copyWith(category: category));
    }
  }

  ZikrFocus? _focusOn(int? zikrId) =>
      zikrId == null ? null : (zikrId: zikrId, serial: ++_focusSerial);

  Future<void> _save(int zikrId, int count) async {
    final current = state;
    if (current is! AzkarReaderLoaded) return;
    final result = await _setCount(
      categoryId: current.category.id,
      zikrId: zikrId,
      count: count,
      day: current.day,
    );
    switch (result) {
      case ApiFailure():
        _reportFailedSave();
      case ApiSuccess(:final data):
        _adoptNewDay(data);
    }
  }

  /// Replaces the counts on screen with [progress]'s when it is from a later
  /// day than they are.
  void _adoptNewDay(AzkarDayProgress progress) {
    final latest = state;
    if (isClosed || latest is! AzkarReaderLoaded) return;
    if (latest.day == null || latest.day == progress.day) return;
    emit(
      latest.copyWith(
        day: () => progress.day,
        counts: progress.countsFor(latest.category.id),
        focus: () => _focusOn(latest.category.azkar.firstOrNull?.id),
      ),
    );
  }

  void _reportFailedSave() {
    final latest = state;
    if (isClosed || latest is! AzkarReaderLoaded) return;
    emit(latest.copyWith(failedSaves: latest.failedSaves + 1));
  }
}
