import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_edition.dart';
import '../repos/quran_cloud_repo.dart';

/// The editions of a kind the reader can choose from, ready to list.
class GetQuranEditionsUseCase {
  final QuranCloudRepo _repo;

  GetQuranEditionsUseCase(this._repo);

  Future<ApiResult<List<QuranEdition>>> call(QuranEditionType type) async {
    final result = await _repo.getEditions(type);
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess(:final data) => ApiResult.success(arrange(type, data)),
    };
  }

  /// * Recitations: the Arabic ones only — the others read a translation
  ///   aloud, which cannot follow the mushaf — each reciter once, as the
  ///   service lists some twice under a second identifier.
  /// * Tafsir: Arabic first.
  /// * Translations: grouped by language, in the order languages first
  ///   appear.
  static List<QuranEdition> arrange(
    QuranEditionType type,
    List<QuranEdition> editions,
  ) {
    final ofType = [
      for (final edition in editions)
        if (edition.type == type) edition,
    ];
    switch (type) {
      case QuranEditionType.recitation:
        final names = <String>{};
        return [
          for (final edition in ofType)
            if (edition.isArabic && names.add(edition.name.trim())) edition,
        ];
      case QuranEditionType.tafsir:
        return [
          ...ofType.where((e) => e.isArabic),
          ...ofType.where((e) => !e.isArabic),
        ];
      case QuranEditionType.translation:
        final byLanguage = <String, List<QuranEdition>>{};
        for (final edition in ofType) {
          (byLanguage[edition.language] ??= []).add(edition);
        }
        return [for (final group in byLanguage.values) ...group];
    }
  }
}
