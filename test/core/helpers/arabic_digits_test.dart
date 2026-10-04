import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';

void main() {
  test('reads Arabic-Indic digits as Western digits', () {
    expect(toWesternDigits('٢٥٥'), '255');
  });

  test('reads the Persian and Urdu digits as Western digits', () {
    expect(toWesternDigits('۱۲۳'), '123');
  });

  test('leaves Western digits and other characters alone', () {
    expect(toWesternDigits('page 12 ص'), 'page 12 ص');
  });

  test('writes Western digits as Arabic-Indic digits', () {
    expect(toArabicDigits('255'), '٢٥٥');
  });

  test('leaves non-digits alone when writing Arabic-Indic digits', () {
    expect(toArabicDigits('3:12 م'), '٣:١٢ م');
  });
}
