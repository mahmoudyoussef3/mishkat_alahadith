import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';

const _base = TextStyle(fontSize: 10);
const _mark = TextStyle(fontSize: 20);

List<String> _pieces(TextSpan span) => [
  for (final child in span.children!) (child as TextSpan).text!,
];

void main() {
  group('styledRanges', () {
    test('styles each range and keeps the text between them', () {
      final span = styledRanges(
        text: 'abcdef',
        base: _base,
        ranges: [(start: 1, end: 3, style: _mark)],
      );

      expect(_pieces(span), ['a', 'bc', 'def']);
      expect((span.children![1] as TextSpan).style, _mark);
    });

    test('trims a range that reaches back over the one before it', () {
      final span = styledRanges(
        text: 'abcdef',
        base: _base,
        ranges: [
          (start: 0, end: 3, style: _mark),
          (start: 2, end: 5, style: _mark),
        ],
      );

      expect(_pieces(span), ['abc', 'de', 'f']);
    });

    test('clamps a range that runs past the end of the text', () {
      final span = styledRanges(
        text: 'abc',
        base: _base,
        ranges: [(start: 1, end: 99, style: _mark)],
      );

      expect(_pieces(span), ['a', 'bc']);
    });
  });

  test('ltrIsolate wraps text in a left-to-right isolate', () {
    expect(ltrIsolate('An-Nisā’'), '\u2066An-Nisā’\u2069');
  });
}
