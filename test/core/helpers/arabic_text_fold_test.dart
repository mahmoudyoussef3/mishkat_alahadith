import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_text_fold.dart';

void main() {
  group('ArabicTextFold.foldSpelling', () {
    test('drops harakat and shadda', () {
      expect(ArabicTextFold.foldSpelling('سُبْحَانَ اللَّهِ'), 'سبحان الله');
    });

    test('merges alef, yeh and teh marbuta variants', () {
      expect(ArabicTextFold.foldSpelling('أإآٱ'), 'اااا');
      expect(ArabicTextFold.foldSpelling('على'), 'علي');
      expect(ArabicTextFold.foldSpelling('الصلاة'), 'الصلاه');
    });

    test('keeps every letter, so different words stay apart', () {
      expect(
        ArabicTextFold.foldSpelling('الناس'),
        isNot(ArabicTextFold.foldSpelling('النساء')),
      );
    });

    test('collapses and trims whitespace', () {
      expect(ArabicTextFold.foldSpelling('  الحمد \n  لله  '), 'الحمد لله');
    });

    test('leaves Latin letters as they are', () {
      expect(ArabicTextFold.foldSpelling('Glory'), 'Glory');
    });
  });
}
