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
}
