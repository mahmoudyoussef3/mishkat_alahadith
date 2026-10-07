import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_flowing_page.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/helpers/quran_ui_helpers.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The basmala the mushaf prints above every surah but At-Tawbah.
const String flowingBasmala = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

/// A word of the flowing layout: which ayah, and where it starts in that
/// ayah's text.
typedef FlowingWordRef = ({int ayahId, int charStart});

/// `[start, end)` of each word of [text]: the runs between spaces, split the
/// way the printed page splits them, so its marks stay on their letters.
List<({int start, int end})> ayahWordRanges(String text) {
  final words = <({int start, int end})>[];
  var at = 0;
  while (at < text.length) {
    if (text[at] == ' ') {
      at++;
      continue;
    }
    var end = at;
    while (end < text.length && text[end] != ' ') {
      end++;
    }
    words.add((start: at, end: end));
    at = end;
  }
  return words;
}

/// The word the tajweed focus is on: the [index]th word of [page] that
/// carries [ruleKey], in reading order, wrapping.
///
/// The printed page counts the same stops — a word carrying the rule twice is
/// still one — so the focus bar's «ن من م» holds in both layouts.
FlowingWordRef? focusedFlowingWord(
  QuranFlowingPage page,
  String ruleKey,
  int index,
) {
  final stops = <FlowingWordRef>[];
  for (final section in page.sections) {
    for (final flowing in section.ayahs) {
      final segments = [
        for (final s in flowing.tajweed)
          if (s.ruleKey == ruleKey) s,
      ];
      if (segments.isEmpty) continue;
      for (final word in ayahWordRanges(flowing.ayah.text)) {
        if (segments.any((s) => s.start < word.end && s.end > word.start)) {
          stops.add((ayahId: flowing.ayah.id, charStart: word.start));
        }
      }
    }
  }
  if (stops.isEmpty) return null;
  return stops[index % stops.length];
}

/// A word laid into a [FlowingRun].
class FlowingWord {
  final int ayahId;

  /// The word as written; the ayah number as drawn for an end marker.
  final String text;

  /// Where the word starts in the run's text.
  final int start;

  /// Where the word starts in its ayah's text; null for an end marker.
  final int? charStart;

  /// The word's coloured rules, relative to the word.
  final List<TajweedSegment> tajweed;

  const FlowingWord({
    required this.ayahId,
    required this.text,
    required this.start,
    required this.charStart,
    this.tajweed = const [],
  });

  bool get isMarker => charStart == null;

  int get end => start + text.length;

  /// The coloured rule under [offset] of the run's text, if any.
  TajweedSegment? segmentAt(int offset) {
    final at = offset - start;
    for (final segment in tajweed) {
      if (at >= segment.start && at < segment.end) return segment;
    }
    return null;
  }
}

/// A surah's ayahs on one page as a single span of running text, with each
/// word's place in it so a tap can be traced back to its word.
class FlowingRun {
  final InlineSpan span;

  /// In the order they appear in the text.
  final List<FlowingWord> words;

  const FlowingRun({required this.span, required this.words});

  /// The word at [offset] of the run's text, or the word before it when the
  /// offset falls in the gap that follows a word.
  FlowingWord? wordAt(int offset) {
    if (words.isEmpty || offset < 0) return null;
    var low = 0;
    var high = words.length - 1;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (words[mid].start <= offset) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    final word = words[low];
    return word.start <= offset ? word : null;
  }

  /// The word [ref] points at, if it is in this run.
  FlowingWord? find(FlowingWordRef ref) => words
      .where((w) => w.ayahId == ref.ayahId && w.charStart == ref.charStart)
      .firstOrNull;

  /// The first word of [ayahId], if the ayah is in this run.
  FlowingWord? firstWordOf(int ayahId) =>
      words.where((w) => w.ayahId == ayahId).firstOrNull;
}

/// Lays [ayahs] out as one run of text in [style], each closed by its
/// numbered rosette.
///
/// With [tajweed] on, each rule is drawn in its colour. [selectedAyahId] is
/// washed in the highlight colour, and [focus] tints one word in
/// `focus.color`.
FlowingRun buildFlowingRun({
  required List<QuranFlowingAyah> ayahs,
  required TextStyle style,
  required MushafColors colors,
  required bool tajweed,
  int? selectedAyahId,
  ({FlowingWordRef word, Color color})? focus,
}) {
  final children = <InlineSpan>[];
  final words = <FlowingWord>[];
  var offset = 0;

  void addText(String text, {Color? color, Color? background}) {
    children.add(
      TextSpan(
        text: text,
        style:
            color == null && background == null
                ? null
                : TextStyle(color: color, backgroundColor: background),
      ),
    );
    offset += text.length;
  }

  for (var a = 0; a < ayahs.length; a++) {
    final ayah = ayahs[a].ayah;
    final selected = ayah.id == selectedAyahId;
    final wash = selected ? colors.highlight : null;
    final ranges = ayahWordRanges(ayah.text);

    for (var i = 0; i < ranges.length; i++) {
      if (i > 0) addText(' ', background: wash);
      final range = ranges[i];
      final text = ayah.text.substring(range.start, range.end);
      final segments =
          tajweed
              ? _wordSegments(ayahs[a].tajweed, range.start, range.end)
              : const <TajweedSegment>[];
      final focusColor =
          focus != null &&
                  focus.word.ayahId == ayah.id &&
                  focus.word.charStart == range.start
              ? focus.color
              : null;

      words.add(
        FlowingWord(
          ayahId: ayah.id,
          text: text,
          start: offset,
          charStart: range.start,
          tajweed: segments,
        ),
      );
      children.add(
        styledRanges(
          text: text,
          base: TextStyle(backgroundColor: focusColor ?? wash),
          ranges: [
            for (final segment in segments)
              if (tajweedRuleOf(segment.ruleKey) case final rule?)
                (
                  start: segment.start,
                  end: segment.end,
                  style: TextStyle(color: colors.tajweedColor(rule)),
                ),
          ],
        ),
      );
      offset += text.length;
    }

    addText(' ', background: wash);
    // Plain text rather than a widget: a paragraph hands its widgets the
    // places on a line from left to right, so two rosettes on one right to
    // left line would trade numbers.
    final marker = ayahMarkerText(ayah.number, style);
    words.add(
      FlowingWord(
        ayahId: ayah.id,
        text: marker,
        start: offset,
        charStart: null,
      ),
    );
    addText(marker, color: colors.accent, background: wash);
    if (a < ayahs.length - 1) addText(' ');
  }

  return FlowingRun(
    span: TextSpan(style: style, children: children),
    words: List.unmodifiable(words),
  );
}

/// The ayah's rules that fall inside `[start, end)`, clipped to it and made
/// relative to it. Rules the rendering package does not know are left out,
/// so a tap on them reaches the ayah instead.
List<TajweedSegment> _wordSegments(
  List<TajweedSegment> ayahSegments,
  int start,
  int end,
) {
  return [
    for (final s in ayahSegments)
      if (s.start < end && s.end > start && tajweedRuleOf(s.ruleKey) != null)
        TajweedSegment(
          start: (s.start < start ? start : s.start) - start,
          end: (s.end > end ? end : s.end) - start,
          ruleKey: s.ruleKey,
        ),
  ];
}

bool? _markerDigitsReversed;

/// [number] in the order the mushaf font folds into a single rosette glyph.
///
/// Whether the shaper receives a run of digits in the order given depends on
/// the platform, so — as the printed page does — the order is measured once:
/// the one that ligates comes out narrower.
String ayahMarkerText(int number, TextStyle style) {
  final digits = toArabicNumerals(number);
  final reversed = _markerDigitsReversed ??= _digitsReversed(style);
  return reversed ? digits.split('').reversed.join() : digits;
}

bool _digitsReversed(TextStyle style) {
  const probe = '٢٥٣';
  double width(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  return width(probe.split('').reversed.join()) < width(probe);
}
