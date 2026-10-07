import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The palette the reader is drawn in for its paper choice. The page takes
/// its colours from it (see `MushafPalette`), and so do the bars and sheets
/// around the page, so night paper is never framed by a light toolbar.
AppPalette readerPalette(MushafThemeMode mode, Brightness appBrightness) {
  return switch (mode) {
    MushafThemeMode.system =>
      appBrightness == Brightness.dark ? AppPalette.dark : AppPalette.light,
    MushafThemeMode.day => AppPalette.light,
    MushafThemeMode.night => AppPalette.dark,
  };
}

/// The designed size of Quran text that wraps freely, before the reader's
/// [QuranFontScale] — the size it has always had in the ayah sheet.
const double _flowingQuranFontSize = 24;

/// The size Quran text that wraps freely is drawn at for [scale]: the
/// flowing layout, the ayah sheet and the size preview.
double quranFontSize(QuranFontScale scale) =>
    _flowingQuranFontSize.sp * scale.factor;

/// Keeps Latin text such as «An-Nisā’» or «‘Abasa» in one left-to-right run
/// inside Arabic text, so its leading or trailing quote mark stays attached
/// instead of jumping to the other side.
String ltrIsolate(String text) => '\u2066$text\u2069';

final Map<String, TajweedRule> _rulesByKey = TajweedRule.values.asNameMap();

/// The rendering package's rule for a domain rule key.
TajweedRule? tajweedRuleOf(String ruleKey) => _rulesByKey[ruleKey];

/// [text] in [base], with each of [ranges] in its own style on top.
///
/// Ranges are taken in order. One that reaches back over an earlier range is
/// trimmed to start where that one ended, and any that fall outside the text
/// are clamped to it.
TextSpan styledRanges({
  required String text,
  required TextStyle base,
  required Iterable<({int start, int end, TextStyle style})> ranges,
}) {
  final children = <TextSpan>[];
  var at = 0;
  for (final range in ranges) {
    final start = range.start.clamp(at, text.length);
    final end = range.end.clamp(start, text.length);
    if (start == end) continue;
    if (start > at) children.add(TextSpan(text: text.substring(at, start)));
    children.add(
      TextSpan(text: text.substring(start, end), style: range.style),
    );
    at = end;
  }
  if (at < text.length) children.add(TextSpan(text: text.substring(at)));
  return TextSpan(style: base, children: children);
}

/// The ayah as it is copied or shared: the verse in ornate brackets and its
/// reference, so it can be quoted anywhere without losing where it is from.
String formatAyahForSharing(AyahDetails details) {
  final text = details.ayah.text.trim();
  final reference = toArabicNumerals(details.ayah.number);
  return '﴿$text﴾\n[سورة ${details.surah.nameArabic}: $reference]';
}

/// «١٢/٣/٢٠٢٦» — short, numeric and locale-independent.
String formatShortDate(DateTime date) =>
    '${toArabicNumerals(date.day)}/${toArabicNumerals(date.month)}/'
    '${toArabicNumerals(date.year)}';

const List<String> _juzOrdinals = [
  'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', //
  'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر',
  'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر', 'الخامس عشر',
  'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
  'الحادي والعشرون', 'الثاني والعشرون', 'الثالث والعشرون',
  'الرابع والعشرون', 'الخامس والعشرون', 'السادس والعشرون',
  'السابع والعشرون', 'الثامن والعشرون', 'التاسع والعشرون', 'الثلاثون',
];

/// «الجزء الأول» … «الجزء الثلاثون».
String juzTitle(int number) =>
    number >= 1 && number <= _juzOrdinals.length
        ? 'الجزء ${_juzOrdinals[number - 1]}'
        : 'الجزء ${toArabicNumerals(number)}';
