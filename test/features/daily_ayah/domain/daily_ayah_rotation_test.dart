import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/services/daily_ayah_rotation.dart';

void main() {
  test('the time of day does not change the pick', () {
    final morning = DailyAyahRotation.indexFor(DateTime(2026, 10, 23, 0, 1), 143);
    final night = DailyAyahRotation.indexFor(
      DateTime(2026, 10, 23, 23, 59),
      143,
    );

    expect(night, morning);
  });

  test('a UTC instant counts by its own calendar date', () {
    expect(
      DailyAyahRotation.dayNumber(DateTime.utc(2026, 10, 23, 23)),
      DailyAyahRotation.dayNumber(DateTime(2026, 10, 23, 1)),
    );
  });

  test('every entry comes up exactly once per cycle', () {
    const length = 143;
    final picks = {
      for (var offset = 0; offset < length; offset++)
        DailyAyahRotation.indexFor(DateTime(2026, 1, 1 + offset), length),
    };

    expect(picks, hasLength(length));
  });

  test('neighbouring catalog entries are not featured on successive days', () {
    const length = 143;
    for (var offset = 0; offset < 60; offset++) {
      final today = DailyAyahRotation.indexFor(DateTime(2026, 1, 1 + offset), length);
      final tomorrow = DailyAyahRotation.indexFor(
        DateTime(2026, 1, 2 + offset),
        length,
      );

      expect((tomorrow - today).abs(), isNot(anyOf(0, 1, length - 1)));
    }
  });

  test('day numbers run on without a gap through a whole year', () {
    final first = DailyAyahRotation.dayNumber(DateTime(2026));

    for (var offset = 1; offset <= 366; offset++) {
      expect(
        DailyAyahRotation.dayNumber(DateTime(2026, 1, 1 + offset)),
        first + offset,
      );
    }
  });

  test('a one-entry catalog always picks that entry', () {
    expect(DailyAyahRotation.indexFor(DateTime(2026, 10, 23), 1), 0);
    expect(DailyAyahRotation.indexFor(DateTime(2031, 2, 7), 1), 0);
  });

  test('an empty catalog is rejected', () {
    expect(
      () => DailyAyahRotation.indexFor(DateTime(2026, 10, 23), 0),
      throwsArgumentError,
    );
  });
}
