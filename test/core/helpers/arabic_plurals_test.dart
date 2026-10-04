import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';

void main() {
  group('arabicCount', () {
    test('uses the bare singular for one', () {
      expect(arabicCount(1, ArabicNoun.book), 'كتاب');
    });

    test('uses the dual for two', () {
      expect(arabicCount(2, ArabicNoun.book), 'كتابان');
    });

    test('uses the plural from three to ten', () {
      expect(arabicCount(3, ArabicNoun.hadith), '٣ أحاديث');
      expect(arabicCount(10, ArabicNoun.hadith), '١٠ أحاديث');
    });

    test('uses the accusative singular from eleven to ninety-nine', () {
      expect(arabicCount(11, ArabicNoun.book), '١١ كتاباً');
      expect(arabicCount(99, ArabicNoun.chapter), '٩٩ باباً');
    });

    test('follows the last two digits above one hundred', () {
      expect(arabicCount(100, ArabicNoun.hadith), '١٠٠ حديث');
      expect(arabicCount(105, ArabicNoun.hadith), '١٠٥ أحاديث');
      expect(arabicCount(7276, ArabicNoun.hadith), '٧٢٧٦ حديثاً');
    });

    test('uses the singular for zero', () {
      expect(arabicCount(0, ArabicNoun.hadith), '٠ حديث');
    });
  });

  group('approximateHadithCount', () {
    test('gives the exact count below a thousand', () {
      expect(approximateHadithCount(950), '٩٥٠ حديثاً');
    });

    test('rounds down to whole thousands', () {
      expect(approximateHadithCount(41234), 'أكثر من ٤١ ألف حديث');
    });

    test('uses the right form of "thousand" for small amounts', () {
      expect(approximateHadithCount(1500), 'أكثر من ألف حديث');
      expect(approximateHadithCount(2100), 'أكثر من ألفي حديث');
      expect(approximateHadithCount(5000), 'أكثر من ٥ آلاف حديث');
    });
  });
}
