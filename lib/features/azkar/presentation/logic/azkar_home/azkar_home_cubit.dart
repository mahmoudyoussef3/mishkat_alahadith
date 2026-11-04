import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_collection.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_search_results.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_suggestion.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_catalog_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_settings_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_favorite_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_suggested_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_today_azkar_progress_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/search_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/toggle_favorite_azkar_use_case.dart';

part 'azkar_home_state.dart';

class AzkarHomeCubit extends Cubit<AzkarHomeState> {
  final GetAzkarCatalogUseCase _getCatalog;
  final SearchAzkarUseCase _search;
  final GetSuggestedAzkarUseCase _getSuggestion;
  final GetTodayAzkarProgressUseCase _getProgress;
  final GetFavoriteAzkarUseCase _getFavorites;
  final ToggleFavoriteAzkarUseCase _toggleFavorite;
  final GetAzkarSettingsUseCase _getSettings;

  /// What is in the search field, kept even before the book has loaded so
  /// a query typed during loading is searched once it has.
  String _query = '';

  AzkarHomeCubit(
    this._getCatalog,
    this._search,
    this._getSuggestion,
    this._getProgress,
    this._getFavorites,
    this._toggleFavorite,
    this._getSettings,
  ) : super(const AzkarHomeLoading());

  Future<void> load() async {
    emit(const AzkarHomeLoading());
    final translation = await _translation();
    final catalog = await _getCatalog(translation);
    if (isClosed) return;

    switch (catalog) {
      case ApiFailure(:final failure):
        emit(AzkarHomeFailure(failure.message));
      case ApiSuccess(data: final categories):
        final personal = await _loadPersonal();
        if (isClosed) return;
        emit(
          AzkarHomeLoaded(
            categories: categories,
            translation: translation,
            suggestion: _getSuggestion(),
            progress: personal.progress,
            favoriteIds: personal.favoriteIds,
            collection: null,
            query: _query,
            searchResults: _resultsFor(categories, _query),
          ),
        );
    }
  }

  /// Picks up what the reader changed: today's counts, the favourites, and
  /// the translation that search looks in.
  Future<void> refresh() async {
    final current = state;
    if (current is! AzkarHomeLoaded) return;

    final translation = await _translation();
    var categories = current.categories;
    var searchedTranslation = current.translation;
    if (translation != current.translation) {
      if (await _getCatalog(translation) case ApiSuccess(:final data)) {
        categories = data;
        searchedTranslation = translation;
      }
    }
    final personal = await _loadPersonal();

    final latest = state;
    if (isClosed || latest is! AzkarHomeLoaded) return;
    emit(
      latest.copyWith(
        categories: categories,
        translation: searchedTranslation,
        suggestion: _getSuggestion(),
        progress: () => personal.progress,
        favoriteIds: () => personal.favoriteIds,
        searchResults: () => _resultsFor(categories, latest.query),
      ),
    );
  }

  void search(String query) {
    _query = query;
    final current = state;
    if (current is! AzkarHomeLoaded) return;
    emit(
      current.copyWith(
        query: query,
        searchResults: () => _resultsFor(current.categories, query),
      ),
    );
  }

  void selectCollection(AzkarCollection? collection) {
    final current = state;
    if (current is! AzkarHomeLoaded || current.collection == collection) {
      return;
    }
    emit(current.copyWith(collection: () => collection));
  }

  /// Whether the change was saved.
  Future<bool> toggleFavorite(int categoryId) async {
    final result = await _toggleFavorite(categoryId);
    if (result case ApiSuccess(data: final added)) {
      final latest = state;
      if (isClosed || latest is! AzkarHomeLoaded) return true;
      final ids = latest.favoriteIds;
      if (ids == null) return true;
      final others = [
        for (final id in ids)
          if (id != categoryId) id,
      ];
      emit(
        latest.copyWith(
          favoriteIds: () => added ? [categoryId, ...others] : others,
        ),
      );
      return true;
    }
    return false;
  }

  AzkarSearchResults? _resultsFor(
    List<AzkarCategory> categories,
    String query,
  ) {
    final trimmed = query.trim();
    if (!_search.canSearch(trimmed)) return null;
    return _search(categories, trimmed);
  }

  Future<AzkarTranslation> _translation() async =>
      switch (await _getSettings()) {
        ApiSuccess(:final data) => data.translation,
        ApiFailure() => AzkarSettings.defaults.translation,
      };

  Future<({AzkarDayProgress? progress, List<int>? favoriteIds})>
  _loadPersonal() async {
    final (progress, favorites) = await (_getProgress(), _getFavorites()).wait;
    return (
      progress: switch (progress) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      },
      favoriteIds: switch (favorites) {
        ApiSuccess(:final data) => data,
        ApiFailure() => null,
      },
    );
  }
}
