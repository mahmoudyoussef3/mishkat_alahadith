import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_flowing_page.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/flowing_text.dart';

import '../quran_fakes.dart';

const _style = TextStyle(fontSize: 20);

QuranFlowingAyah _flowing(
  QuranAyah ayah, [
  List<TajweedSegment> rules = const [],
]) => QuranFlowingAyah(ayah: ayah, tajweed: rules);

FlowingRun _run(
  List<QuranFlowingAyah> ayahs, {
  bool tajweed = true,
  int? selectedAyahId,
}) => buildFlowingRun(
  ayahs: ayahs,
  style: _style,
  colors: MushafPalette.light,
  tajweed: tajweed,
  selectedAyahId: selectedAyahId,
);

/// The text of [span] drawn over [background], each span taking the style
/// of the spans around it.
String _textOn(InlineSpan span, Color background, [TextStyle? inherited]) {
  if (span is! TextSpan) return '';
  final style = inherited == null ? span.style : inherited.merge(span.style);
  final own = style?.backgroundColor == background ? span.text ?? '' : '';
  return own +
      [
        for (final child in span.children ?? const <InlineSpan>[])
          _textOn(child, background, style),
      ].join();
}

void main() {
  group('buildFlowingRun', () {
    test('places every word and marker where it sits in the run text', () {
      final run = _run([_flowing(basmalah), _flowing(hamd)]);
      final text = run.span.toPlainText();

      for (final word in run.words) {
        expect(text.substring(word.start, word.end), word.text);
      }
    });

    test('closes each ayah with its numbered marker', () {
      final run = _run([_flowing(basmalah), _flowing(hamd)]);
      final markers = run.words.where((w) => w.isMarker).toList();

      expect(markers.map((m) => (m.ayahId, m.text)), [(1, '١'), (2, '٢')]);
    });

    test('draws the markers as text, so a line keeps them in order', () {
      final run = _run([_flowing(basmalah), _flowing(hamd)]);

      // A paragraph places its widgets from left to right, which would swap
      // two rosettes on one right-to-left line.
      run.span.visitChildren((span) {
        expect(span, isNot(isA<WidgetSpan>()));
        return true;
      });
    });

    test('a tap in the gap after a word belongs to that word', () {
      final run = _run([_flowing(hamd)]);
      final first = run.words.first;

      expect(run.wordAt(first.end), same(first));
    });

    test('a tap before the text finds no word', () {
      expect(_run([_flowing(hamd)]).wordAt(-1), isNull);
    });

    test('finds the coloured rule under a tap, relative to its word', () {
      final run = _run([
        _flowing(hamd, const [
          TajweedSegment(start: 11, end: 14, ruleKey: 'ghunna'),
        ]),
      ]);
      final word = run.words[1];

      final segment = word.segmentAt(word.start + 2);

      expect(segment?.ruleKey, 'ghunna');
      expect((segment?.start, segment?.end), (1, 4));
      expect(word.segmentAt(word.start), isNull);
    });

    test('carries no rules while tajweed is off', () {
      final run = _run([
        _flowing(hamd, const [
          TajweedSegment(start: 11, end: 14, ruleKey: 'ghunna'),
        ]),
      ], tajweed: false);

      expect(run.words.expand((w) => w.tajweed), isEmpty);
    });

    test('leaves out a rule the renderer does not know', () {
      final run = _run([
        _flowing(hamd, const [
          TajweedSegment(start: 11, end: 14, ruleKey: 'notARule'),
        ]),
      ]);

      expect(run.words[1].tajweed, isEmpty);
    });

    test('washes only the selected ayah', () {
      final run = _run([_flowing(basmalah), _flowing(hamd)], selectedAyahId: 2);

      final washed = _textOn(run.span, MushafPalette.light.highlight);

      expect(washed, contains('لِلَّهِ'));
      expect(washed, isNot(contains('بِسۡمِ')));
    });

    test('find and firstWordOf locate words by ayah', () {
      final run = _run([_flowing(basmalah), _flowing(hamd)]);

      expect(run.find((ayahId: 2, charStart: 10))?.text, 'لِلَّهِ');
      expect(run.firstWordOf(2)?.charStart, 0);
      expect(run.firstWordOf(99), isNull);
    });
  });
}
