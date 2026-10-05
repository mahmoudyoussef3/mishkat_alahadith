import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_time_format.dart';

void main() {
  group('formatArabicClock', () {
    test('writes afternoon times on a 12-hour clock with م', () {
      expect(formatArabicClock(DateTime(2026, 10, 4, 15, 12)), '٣:١٢ م');
    });

    test('writes midnight as twelve with ص', () {
      expect(formatArabicClock(DateTime(2026, 10, 4, 0, 5)), '١٢:٠٥ ص');
    });

    test('writes noon as twelve with م', () {
      expect(formatArabicClock(DateTime(2026, 10, 4, 12, 0)), '١٢:٠٠ م');
    });
  });

  group('formatArabicCountdown', () {
    test('counts minutes alone under an hour', () {
      expect(formatArabicCountdown(const Duration(minutes: 42)), '٤٢ دقيقة');
    });

    test('rounds partial minutes up', () {
      expect(
        formatArabicCountdown(const Duration(minutes: 4, seconds: 10)),
        '٥ دقائق',
      );
    });

    test('uses the genitive dual after "بعد"', () {
      expect(formatArabicCountdown(const Duration(minutes: 2)), 'دقيقتين');
      expect(formatArabicCountdown(const Duration(hours: 2)), 'ساعتين');
    });

    test('joins hours and minutes with و', () {
      expect(
        formatArabicCountdown(const Duration(hours: 2, minutes: 10)),
        'ساعتين و١٠ دقائق',
      );
    });

    test('says "less than a minute" when the time has come', () {
      expect(formatArabicCountdown(Duration.zero), 'أقل من دقيقة');
    });
  });

  group('formatArabicGregorianDate', () {
    test('writes the day, Arabic month name and year', () {
      expect(formatArabicGregorianDate(DateTime(2026, 10, 5)), '٥ أكتوبر ٢٠٢٦');
    });
  });

  group('formatArabicDayAndTime', () {
    final now = DateTime(2026, 10, 5, 18, 0);

    test('says today for a time earlier the same day', () {
      expect(
        formatArabicDayAndTime(DateTime(2026, 10, 5, 10, 32), now: now),
        'اليوم ١٠:٣٢ ص',
      );
    });

    test('says yesterday for the previous calendar day', () {
      expect(
        formatArabicDayAndTime(DateTime(2026, 10, 4, 23, 59), now: now),
        'أمس ١١:٥٩ م',
      );
    });

    test('writes the date for older days', () {
      expect(
        formatArabicDayAndTime(DateTime(2026, 9, 28, 9, 5), now: now),
        '٢٨ سبتمبر ٩:٠٥ ص',
      );
    });
  });
}
