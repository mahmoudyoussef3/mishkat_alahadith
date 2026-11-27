import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';

import '../../domain/entities/daily_ayah.dart';
import '../../domain/services/daily_ayah_rotation.dart';
import '../models/daily_ayah_notification.dart';

extension DailyAyahMapper on DailyAyah {
  DailyAyahPayload get payload => DailyAyahPayload(
    ayahId: ayah.id,
    page: ayah.page,
    surahNumber: surah.number,
  );

  /// «سورة البقرة · الآية ٢٥٥»
  String get reference =>
      'سورة ${surah.nameArabic} · الآية ${toArabicDigits('${ayah.number}')}';

  /// Days since 1 January 1970: how the native widget finds today's entry.
  int get dayNumber => DailyAyahRotation.dayNumber(day);

  /// One day of the widget's data, already worded, so the native side only
  /// has to show it.
  Map<String, Object> toWidgetEntry() => {
    'day': dayNumber,
    'text': '﴿${DailyAyahText.forMushafFont(ayah.text)}﴾',
    'reference': reference,
    'page': 'الصفحة ${toArabicDigits('${ayah.page}')}',
    'payload': payload.encode(),
  };
}

extension DailyAyahReminderMapper on DailyAyahReminder {
  /// Clear of the ids other notifications use: prayer reminders are numbered
  /// by date in the low hundreds of millions, pushes by the second they
  /// arrive, in the billions.
  static const int _idBase = 700000000;

  DailyAyahNotification toNotification() => DailyAyahNotification(
    // One id per day, so rescheduling a day replaces it.
    id: _idBase + dailyAyah.dayNumber,
    title: 'آية اليوم',
    body: '﴿${DailyAyahText.forSystemFont(dailyAyah.ayah.text)}﴾',
    subtitle: dailyAyah.reference,
    payload: dailyAyah.payload.encode(),
    fireAt: fireAt,
  );
}

/// The ayah's text made ready for display outside the mushaf.
abstract final class DailyAyahText {
  /// «۞» opens the ayahs that begin a quarter hizb: a mark for dividing the
  /// mushaf, not part of the verse, so it is left out of a lone ayah.
  static const String _rubElHizb = '۞';

  /// For the mushaf's own font, as the widget uses: the text as printed.
  static String forMushafFont(String text) =>
      text.replaceAll(_rubElHizb, '').trim();

  /// For the system font, as notifications use.
  ///
  /// The mushaf's encoding writes the stacked tanween with codepoints other
  /// fonts draw as different marks — U+0656 comes out as a subscript alef —
  /// so they are written as the plain tanween every Arabic font has.
  static String forSystemFont(String text) {
    final buffer = StringBuffer();
    for (final unit in forMushafFont(text).codeUnits) {
      buffer.writeCharCode(switch (unit) {
        0x0657 => 0x064B, // stacked fathatan
        0x065E => 0x064C, // stacked dammatan
        0x0656 => 0x064D, // stacked kasratan
        _ => unit,
      });
    }
    return buffer.toString();
  }
}
