import '../entities/quran_edition.dart';
import '../services/quran_text_normalizer.dart';

/// Narrows a list of editions by name, English name, language code or
/// identifier — «سديس», «sudais», «ur», «en.sahih».
class FilterQuranEditionsUseCase {
  List<QuranEdition> call(List<QuranEdition> editions, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return editions;
    final arabic = QuranTextNormalizer.foldSpelling(trimmed);
    final latin = trimmed.toLowerCase();
    return [
      for (final edition in editions)
        if ((arabic.isNotEmpty &&
                QuranTextNormalizer.foldSpelling(
                  edition.name,
                ).contains(arabic)) ||
            edition.englishName.toLowerCase().contains(latin) ||
            edition.language.toLowerCase() == latin ||
            edition.identifier.toLowerCase().contains(latin))
          edition,
    ];
  }
}
