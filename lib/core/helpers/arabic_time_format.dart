import 'package:hijri/hijri_calendar.dart';

import 'arabic_digits.dart';
import 'arabic_plurals.dart';

/// 12-hour clock time with Arabic-Indic digits and an ص/م suffix:
/// 15:12 → "٣:١٢ م", 00:05 → "١٢:٠٥ ص".
String formatArabicClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'ص' : 'م';
  return toArabicDigits('$hour:$minute $period');
}

/// How long until an event, to follow "بعد": 42 min → "٤٢ دقيقة",
/// 2 h 10 min → "ساعتين و١٠ دقائق". Seconds are dropped, rounding up so a
/// countdown never reads zero before the event.
String formatArabicCountdown(Duration remaining) {
  final totalMinutes = (remaining.inSeconds / 60).ceil();
  if (totalMinutes <= 0) return 'أقل من دقيقة';

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  final hourPart = hours > 0 ? arabicCount(hours, ArabicNoun.hour) : null;
  final minutePart =
      minutes > 0 ? arabicCount(minutes, ArabicNoun.minute) : null;

  return switch ((hourPart, minutePart)) {
    (final h?, final m?) => '$h و$m',
    (final h?, null) => h,
    (null, final m?) => m,
    (null, null) => 'أقل من دقيقة',
  };
}

const _gregorianMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

const _weekdays = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

/// Day of the week in Arabic: "الاثنين".
String arabicWeekday(DateTime date) => _weekdays[date.weekday - 1];

/// Gregorian date in Arabic: "٥ أكتوبر ٢٠٢٦".
String formatArabicGregorianDate(DateTime date) =>
    toArabicDigits('${date.day} ${_gregorianMonths[date.month - 1]} ${date.year}');

/// A recent moment relative to [now]: "اليوم ١٠:٣٢ ص", "أمس ١٠:٣٢ ص", or
/// "٥ أكتوبر ١٠:٣٢ ص" for older days.
String formatArabicDayAndTime(DateTime time, {required DateTime now}) {
  final dayLabel = switch (_calendarDaysBetween(time, now)) {
    0 => 'اليوم',
    1 => 'أمس',
    _ => toArabicDigits('${time.day} ${_gregorianMonths[time.month - 1]}'),
  };
  return '$dayLabel ${formatArabicClock(time)}';
}

/// Whole calendar days from [from] to [to], counted on UTC dates so a
/// daylight-saving change (a 23- or 25-hour day) does not skew it.
int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// How long ago [time] was, by calendar day: "اليوم", "أمس", "منذ ٣ أيام"
/// within a week, otherwise the date ("٢٨ سبتمبر").
String formatArabicRelativeDay(DateTime time, {required DateTime now}) {
  final daysAgo = _calendarDaysBetween(time, now);
  return switch (daysAgo) {
    <= 0 => 'اليوم',
    1 => 'أمس',
    <= 7 => 'منذ ${arabicCount(daysAgo, _day)}',
    _ => toArabicDigits('${time.day} ${_gregorianMonths[time.month - 1]}'),
  };
}

const _day = ArabicNoun(
  singular: 'يوم',
  dual: 'يومين',
  plural: 'أيام',
  accusative: 'يوماً',
);

/// Umm al-Qura date in Arabic: "١٢ ربيع الآخر ١٤٤٨".
String formatArabicHijriDate(DateTime date) {
  HijriCalendar.setLocal('ar');
  final hijri = HijriCalendar.fromDate(date);
  return toArabicDigits(
    '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear}',
  );
}
