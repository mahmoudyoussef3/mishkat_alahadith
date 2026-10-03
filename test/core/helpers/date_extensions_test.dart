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
}
