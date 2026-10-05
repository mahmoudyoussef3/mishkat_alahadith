import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/reading_preferences/domain/entities/hadith_font_scale.dart';

void main() {
  test('sizes grow from small to extra large', () {
    final factors = [for (final scale in HadithFontScale.values) scale.factor];

    expect(factors, [...factors]..sort());
    expect(HadithFontScale.medium.factor, 1.0);
  });

  test('larger steps up one size', () {
    expect(HadithFontScale.medium.larger, HadithFontScale.large);
  });

  test('larger stays at the largest size', () {
    expect(HadithFontScale.extraLarge.larger, HadithFontScale.extraLarge);
  });

  test('smaller steps down one size', () {
    expect(HadithFontScale.medium.smaller, HadithFontScale.small);
  });

  test('smaller stays at the smallest size', () {
    expect(HadithFontScale.small.smaller, HadithFontScale.small);
  });
}
