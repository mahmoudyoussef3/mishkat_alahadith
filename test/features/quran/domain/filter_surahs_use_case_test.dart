import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';

import '../quran_fakes.dart';

void main() {
  final filter = FilterSurahsUseCase();

  test('an empty query keeps every surah', () {
    expect(filter(sampleSurahs, '  '), sampleSurahs);
  });

  test('matches the Arabic name without the teh marbuta', () {
    expect(filter(sampleSurahs, 'بقره'), [baqarah]);
  });

  test('matches the English name without its accents', () {
    expect(filter(sampleSurahs, 'fatihah'), [fatihah]);
  });

  test('matches by number as a prefix while it is typed', () {
    expect(filter(sampleSurahs, '11'), [nas]);
  });

  test('reads Arabic-Indic digits as a number', () {
    expect(filter(sampleSurahs, '١١٤'), [nas]);
  });

  test('returns nothing when no surah matches', () {
    expect(filter(sampleSurahs, 'الكهف'), isEmpty);
  });
}
