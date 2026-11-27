import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';

void main() {
  group('HadithGrade.tryParse', () {
    test('reads Arabic grades', () {
      expect(HadithGrade.tryParse('صحيح'), HadithGrade.sahih);
      expect(HadithGrade.tryParse('حسن'), HadithGrade.hasan);
      expect(HadithGrade.tryParse('ضعيف'), HadithGrade.daif);
    });

    test('reads English grades in any case', () {
      expect(HadithGrade.tryParse('Sahih'), HadithGrade.sahih);
      expect(HadithGrade.tryParse('HASAN'), HadithGrade.hasan);
      expect(HadithGrade.tryParse("Da'if"), HadithGrade.daif);
    });

    test('reads a qualified grade by its main word', () {
      expect(HadithGrade.tryParse('صحيح لغيره'), HadithGrade.sahih);
      expect(HadithGrade.tryParse('ضعيف جداً'), HadithGrade.daif);
    });

    test('treats "حسن صحيح" as authentic', () {
      expect(HadithGrade.tryParse('حسن صحيح'), HadithGrade.sahih);
    });

    test('lets a weak qualifier win over other words', () {
      expect(HadithGrade.tryParse('إسناده ضعيف ومتنه صحيح'), HadithGrade.daif);
    });

    test('treats fabricated hadiths as weak', () {
      expect(HadithGrade.tryParse('موضوع'), HadithGrade.daif);
    });

    test('returns null for empty text and for non-grades such as a position',
        () {
      expect(HadithGrade.tryParse(null), isNull);
      expect(HadithGrade.tryParse('  '), isNull);
      expect(HadithGrade.tryParse('٣'), isNull);
      expect(HadithGrade.tryParse('12'), isNull);
    });
  });
}
