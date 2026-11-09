import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mushaf_text/mushaf_text.dart' show toArabicNumerals;

import 'quran_ui_helpers.dart';

/// «الحزب ٣», «ربع الحزب ٣», «نصف الحزب ٣», «ثلاثة أرباع الحزب ٣».
String hizbQuarterTitle(int number) {
  final hizb = toArabicNumerals(QuranHizbQuarter.hizbOf(number));
  return switch (QuranHizbQuarter.quarterOf(number)) {
    0 => 'الحزب $hizb',
    1 => 'ربع الحزب $hizb',
    2 => 'نصف الحزب $hizb',
    _ => 'ثلاثة أرباع الحزب $hizb',
  };
}

/// What the well of a quarter's row shows: the hizb's number where it
/// begins, else the fraction of it passed.
String hizbQuarterMark(QuranHizbQuarter quarter) => switch (quarter.quarter) {
  0 => toArabicNumerals(quarter.hizb),
  1 => '¼',
  2 => '½',
  _ => '¾',
};

/// The part of the mushaf being recited, for the player and its sheet.
String recitationScopeTitle(RecitationScope scope, {String? surahName}) =>
    switch (scope.kind) {
      RecitationScopeKind.surah =>
        surahName == null || surahName.isEmpty
            ? 'السورة ${toArabicNumerals(scope.number)}'
            : 'سورة $surahName',
      RecitationScopeKind.page => 'الصفحة ${toArabicNumerals(scope.number)}',
      RecitationScopeKind.juz => juzTitle(scope.number),
      RecitationScopeKind.hizbQuarter => hizbQuarterTitle(scope.number),
    };

/// «سورة البقرة · الآية ٢٥٥».
String recitationTrackTitle(RecitationTrack track) =>
    'سورة ${track.surahName} · الآية ${toArabicNumerals(track.ayahNumber)}';

String ayahRepeatLabel(AyahRepeat repeat) => switch (repeat) {
  AyahRepeat.always => '∞',
  _ => toArabicNumerals(repeat.times!),
};

String ayahRepeatDescription(AyahRepeat repeat) => switch (repeat) {
  AyahRepeat.once => 'تُتلى كل آية مرة واحدة',
  AyahRepeat.twice => 'تُتلى كل آية مرتين',
  AyahRepeat.thrice => 'تُتلى كل آية ثلاث مرات',
  AyahRepeat.fiveTimes => 'تُتلى كل آية خمس مرات',
  AyahRepeat.always => 'تتكرر الآية حتى تنتقل إلى غيرها — للحفظ',
};

String recitationSpeedLabel(RecitationSpeed speed) => switch (speed) {
  RecitationSpeed.slower => '٠٫٧٥×',
  RecitationSpeed.normal => '١×',
  RecitationSpeed.faster => '١٫٢٥×',
  RecitationSpeed.fastest => '١٫٥×',
};

String editionPickerTitle(QuranEditionType type) => switch (type) {
  QuranEditionType.recitation => 'اختر القارئ',
  QuranEditionType.tafsir => 'اختر التفسير',
  QuranEditionType.translation => 'اختر الترجمة',
};

/// The edition's language in Arabic, or its code when it is not one the
/// service commonly offers.
String languageName(String code) => _languageNames[code] ?? code;

/// The text direction of an edition's passages.
TextDirection editionDirection(QuranEdition edition) =>
    edition.isRightToLeft ? TextDirection.rtl : TextDirection.ltr;

/// The glyph pointing to the next item in reading order: left in Arabic.
IconData nextIcon(TextDirection direction) =>
    direction == TextDirection.rtl
        ? Icons.skip_previous_rounded
        : Icons.skip_next_rounded;

IconData previousIcon(TextDirection direction) =>
    direction == TextDirection.rtl
        ? Icons.skip_next_rounded
        : Icons.skip_previous_rounded;

const Map<String, String> _languageNames = {
  'ar': 'العربية',
  'am': 'الأمهرية',
  'az': 'الأذربيجانية',
  'ba': 'البشكيرية',
  'ber': 'الأمازيغية',
  'bg': 'البلغارية',
  'bn': 'البنغالية',
  'bs': 'البوسنية',
  'ce': 'الشيشانية',
  'cs': 'التشيكية',
  'de': 'الألمانية',
  'dv': 'الديفيهية',
  'en': 'الإنجليزية',
  'es': 'الإسبانية',
  'fa': 'الفارسية',
  'fr': 'الفرنسية',
  'ha': 'الهوسا',
  'hi': 'الهندية',
  'id': 'الإندونيسية',
  'it': 'الإيطالية',
  'ja': 'اليابانية',
  'kk': 'الكازاخية',
  'ko': 'الكورية',
  'ku': 'الكردية',
  'ml': 'المالايالامية',
  'ms': 'الملايوية',
  'my': 'البورمية',
  'nl': 'الهولندية',
  'no': 'النرويجية',
  'pl': 'البولندية',
  'ps': 'البشتو',
  'pt': 'البرتغالية',
  'ro': 'الرومانية',
  'ru': 'الروسية',
  'sd': 'السندية',
  'si': 'السنهالية',
  'so': 'الصومالية',
  'sq': 'الألبانية',
  'sv': 'السويدية',
  'sw': 'السواحيلية',
  'ta': 'التاميلية',
  'tg': 'الطاجيكية',
  'th': 'التايلاندية',
  'tr': 'التركية',
  'tt': 'التتارية',
  'ug': 'الأويغورية',
  'ur': 'الأردية',
  'uz': 'الأوزبكية',
  'zh': 'الصينية',
};
