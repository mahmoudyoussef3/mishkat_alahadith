import 'dart:developer';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/azkar_category.dart';
import '../../domain/entities/azkar_day_progress.dart';
import '../../domain/entities/azkar_settings.dart';
import '../../domain/repos/azkar_repo.dart';
import '../datasources/azkar_catalog_local_datasource.dart';
import '../datasources/azkar_preferences_local_datasource.dart';
import '../mappers/azkar_mappers.dart';

class AzkarRepoImpl implements AzkarRepo {
  static const String _arabic = 'ar';

  final AzkarCatalogLocalDataSource _catalog;
  final AzkarPreferencesLocalDataSource _preferences;

  /// The tails of the write queues; see [updateFavoriteIds] and
  /// [updateProgress].
  Future<void> _favoriteWrites = Future.value();
  Future<void> _progressWrites = Future.value();

  AzkarRepoImpl(this._catalog, this._preferences);

  @override
  Future<ApiResult<List<AzkarCategory>>> getCategories(
    AzkarTranslation translation,
  ) async {
    try {
      final languageCode = translation.languageCode;
      final (arabic, translated) =
          await (
            _catalog.getCategories(_arabic),
            languageCode == null
                ? Future.value(null)
                : _catalog.getCategories(languageCode),
          ).wait;
      return ApiResult.success(mergeAzkarCatalog(arabic, translated));
    } catch (error, stackTrace) {
      log('Azkar catalogue failed', error: error, stackTrace: stackTrace);
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<List<int>>> getFavoriteIds() async {
    try {
      return ApiResult.success(await _preferences.getFavoriteIds());
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<List<int>>> updateFavoriteIds(
    List<int> Function(List<int> current) change,
  ) {
    final result = _favoriteWrites.then((_) => _applyFavoriteChange(change));
    _favoriteWrites = result;
    return result;
  }

  Future<ApiResult<List<int>>> _applyFavoriteChange(
    List<int> Function(List<int> current) change,
  ) async {
    try {
      final updated = change(await _preferences.getFavoriteIds());
      await _preferences.saveFavoriteIds(updated);
      return ApiResult.success(updated);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<AzkarDayProgress?>> getProgress() async {
    try {
      return ApiResult.success((await _preferences.getProgress())?.toEntity());
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<AzkarDayProgress>> updateProgress(
    AzkarDayProgress Function(AzkarDayProgress? stored) change,
  ) {
    final result = _progressWrites.then((_) => _applyProgressChange(change));
    _progressWrites = result;
    return result;
  }

  Future<ApiResult<AzkarDayProgress>> _applyProgressChange(
    AzkarDayProgress Function(AzkarDayProgress? stored) change,
  ) async {
    // Progress that can no longer be read is replaced rather than kept
    // blocking every count after it.
    AzkarDayProgress? stored;
    try {
      stored = (await _preferences.getProgress())?.toEntity();
    } catch (error, stackTrace) {
      log(
        'Stored azkar progress unreadable',
        error: error,
        stackTrace: stackTrace,
      );
    }
    try {
      final updated = change(stored);
      await _preferences.saveProgress(updated.toModel());
      return ApiResult.success(updated);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<AzkarSettings>> getSettings() async {
    try {
      final stored = await _preferences.getSettings();
      const defaults = AzkarSettings.defaults;
      return ApiResult.success(
        AzkarSettings(
          translation:
              AzkarTranslation.values.asNameMap()[stored.translation] ??
              defaults.translation,
          fontScale:
              AzkarFontScale.values.asNameMap()[stored.fontScale] ??
              defaults.fontScale,
          hapticFeedback: stored.hapticFeedback ?? defaults.hapticFeedback,
          autoAdvance: stored.autoAdvance ?? defaults.autoAdvance,
        ),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveSettings(AzkarSettings settings) async {
    try {
      await _preferences.saveSettings(
        translation: settings.translation.name,
        fontScale: settings.fontScale.name,
        hapticFeedback: settings.hapticFeedback,
        autoAdvance: settings.autoAdvance,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }
}
