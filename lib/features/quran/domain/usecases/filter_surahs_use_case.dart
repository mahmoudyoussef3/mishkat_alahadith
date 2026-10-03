import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';

import '../entities/quran_surah.dart';
import '../services/quran_text_normalizer.dart';

/// Narrows the surah index by Arabic name, English name or number.
class FilterSurahsUseCase {
  List<QuranSurah> call(List<QuranSurah> surahs, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return surahs;

    final number = int.tryParse(toWesternDigits(trimmed));
    if (number != null) {
      return [
        for (final surah in surahs)
          if (surah.number.toString().startsWith(number.toString())) surah,
      ];
    }

    final arabic = QuranTextNormalizer.foldSpelling(trimmed);
    final latin = _foldLatin(trimmed);
    return [
      for (final surah in surahs)
        if ((arabic.isNotEmpty &&
                QuranTextNormalizer.foldSpelling(
                  surah.nameArabic,
                ).contains(arabic)) ||
            (latin.isNotEmpty && _foldLatin(surah.nameEnglish).contains(latin)))
          surah,
    ];
  }

  /// «Al-Fātiḥah» and «al fatihah» compare equal: letters only, no marks.
  static String _foldLatin(String input) {
    const accents = {
      'ā': 'a', 'á': 'a', 'ī': 'i', 'í': 'i', 'ū': 'u', 'ú': 'u', //
      'ḥ': 'h', 'ṣ': 's', 'ḍ': 'd', 'ṭ': 't', 'ẓ': 'z',
    };
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      final folded = accents[char] ?? char;
      final unit = folded.codeUnitAt(0);
      final isLetter = unit >= 0x61 && unit <= 0x7A;
      if (isLetter) buffer.write(folded);
    }
    return buffer.toString();
  }
}
