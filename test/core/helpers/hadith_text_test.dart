import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';

void main() {
  test('splits a Sunnah.com text at its marked quote', () {
    const text =
        'حَدَّثَنَا عُبَيْدُ اللَّهِ بْنُ مُوسَى، عَنِ ابْنِ عُمَرَ قَالَ قَالَ '
        'رَسُولُ اللَّهِ صلى الله عليه وسلم ‏ "‏ بُنِيَ الإِسْلاَمُ '
        'عَلَى خَمْسٍ ‏"‏‏.‏';

    final parts = HadithTextParts.split(text);

    expect(
      parts.isnad,
      'حَدَّثَنَا عُبَيْدُ اللَّهِ بْنُ مُوسَى، عَنِ ابْنِ عُمَرَ قَالَ قَالَ '
      'رَسُولُ اللَّهِ صلى الله عليه وسلم',
    );
    expect(parts.matn, '«بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ».');
  });

  test('splits at a guillemet after the chain', () {
    const text =
        'عَنْ أَبِي هُرَيْرَةَ رَضِيَ اللَّهُ عَنْهُ قَالَ: قَالَ رَسُولُ اللَّهِ: '
        '«الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ»';

    final parts = HadithTextParts.split(text);

    expect(parts.isnad, endsWith('قَالَ رَسُولُ اللَّهِ:'));
    expect(parts.matn, '«الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ»');
  });

  test('keeps the whole text as matn when nothing is quoted', () {
    const text = 'حَدَّثَنِي أَبُو خَيْثَمَةَ قَالَ: كَانَ أَوَّلَ مَنْ قَالَ';

    final parts = HadithTextParts.split(text);

    expect(parts.isnad, isNull);
    expect(parts.matn, text);
  });

  test('keeps a short lead-in with the quoted words', () {
    const text = 'قَالَ: «لَا ضَرَرَ وَلَا ضِرَارَ»';

    final parts = HadithTextParts.split(text);

    expect(parts.isnad, isNull);
    expect(parts.matn, text);
  });

  test('typeset turns paired straight quotes into guillemets', () {
    expect(
      HadithTextParts.typeset('قال ‏ "‏ نعم ‏"‏'),
      'قال «نعم»',
    );
  });
}
