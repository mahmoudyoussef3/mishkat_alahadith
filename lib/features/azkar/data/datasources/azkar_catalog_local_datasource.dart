import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/azkar_category_model.dart';

/// Hisn Al-Muslim as bundled from the Islamic-Pro-azkar-API data files: one
/// JSON file per language, decoded once and kept for the life of the app.
class AzkarCatalogLocalDataSource {
  static const String _directory = 'assets/azkar';

  final AssetBundle _bundle;
  final Map<String, Future<List<AzkarCategoryModel>>> _loads = {};

  AzkarCatalogLocalDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  /// The chapters in [languageCode] («ar», «en», «tr»), in source order.
  ///
  /// Throws [FormatException] when the file is not a JSON list. A failed load
  /// is forgotten, so the next call tries again.
  Future<List<AzkarCategoryModel>> getCategories(String languageCode) =>
      _loads[languageCode] ??= _load(languageCode).then(
        (categories) => categories,
        onError: (Object error, StackTrace stackTrace) {
          _loads.remove(languageCode);
          Error.throwWithStackTrace(error, stackTrace);
        },
      );

  Future<List<AzkarCategoryModel>> _load(String languageCode) async {
    final raw = await _bundle.loadString('$_directory/$languageCode.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('Azkar file "$languageCode" is not a list');
    }
    return List.unmodifiable([
      for (final entry in decoded)
        if (AzkarCategoryModel.tryFromJson(entry) case final category?)
          category,
    ]);
  }
}
