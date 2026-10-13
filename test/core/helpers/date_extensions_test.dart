import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/helpers/date_extensions.dart';

void main() {
  test('is the next date even on a 25-hour DST day', () {
    // Egypt falls back at the end of 2026-10-29, so adding 24 hours to just
    // after midnight lands on the same day there.
    final justAfterMidnight = DateTime(2026, 10, 29, 0, 0, 1);

    expect(justAfterMidnight.nextCalendarDay, DateTime(2026, 10, 30));
  });

  test('is the next date even on a 23-hour DST day', () {
    // Egypt springs forward at the start of 2026-04-24.
    final lateEvening = DateTime(2026, 4, 23, 23, 30);

    expect(lateEvening.nextCalendarDay, DateTime(2026, 4, 24));
  });

  test('rolls over the month and year', () {
    expect(DateTime(2026, 12, 31, 23, 59).nextCalendarDay, DateTime(2027));
  });

  group('daysInMonth', () {
    test('is 30 for a 30-day month', () {
      expect(DateTime(2026, 9, 15).daysInMonth, 30);
    });

    test('is 31 for a 31-day month', () {
      expect(DateTime(2026, 10, 7).daysInMonth, 31);
    });

    test('is 28 for February in a common year', () {
      expect(DateTime(2026, 2, 1).daysInMonth, 28);
    });

    test('is 29 for February in a leap year', () {
      expect(DateTime(2028, 2, 29).daysInMonth, 29);
    });

    test('is 31 for December without spilling into the next year', () {
      expect(DateTime(2026, 12, 31, 23, 59).daysInMonth, 31);
    });
  });
}
