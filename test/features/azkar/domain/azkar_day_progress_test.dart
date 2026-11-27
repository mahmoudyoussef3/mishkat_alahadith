import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';

import '../azkar_fakes.dart';

void main() {
  final today = AzkarDayProgress.emptyOn(DateTime(2026, 11, 5, 7));

  group('AzkarDayProgress', () {
    test('a day is counted from local midnight', () {
      expect(today.day, DateTime(2026, 11, 5));
      expect(today.isOn(DateTime(2026, 11, 5, 23, 59)), isTrue);
      expect(today.isOn(DateTime(2026, 11, 6)), isFalse);
    });

    test('currentOf keeps progress from the same day', () {
      final stored = today.withCount(27, 1, 1);

      expect(
        AzkarDayProgress.currentOf(stored, DateTime(2026, 11, 5, 20)),
        same(stored),
      );
    });

    test('currentOf starts afresh on a new day', () {
      final stored = today.withCount(27, 1, 1);

      final next = AzkarDayProgress.currentOf(stored, DateTime(2026, 11, 6, 5));

      expect(next.day, DateTime(2026, 11, 6));
      expect(next.counts, isEmpty);
    });

    test('withCount records a count for one zikr', () {
      final progress = today.withCount(27, 2, 2);

      expect(progress.countOf(27, 2), 2);
      expect(progress.countOf(27, 1), 0);
    });

    test('a count of zero forgets the zikr and an emptied chapter', () {
      final progress = today.withCount(27, 2, 2).withCount(27, 2, 0);

      expect(progress.counts, isEmpty);
    });

    test('withoutCategory clears one chapter only', () {
      final progress = today
          .withCount(27, 1, 1)
          .withCount(28, 1, 1)
          .withoutCategory(27);

      expect(progress.counts.keys, [28]);
    });
  });

  group('AzkarCategoryProgress', () {
    test('counts repetitions and finished azkar', () {
      final progress = today
          .withCount(27, 1, 1)
          .withCount(27, 2, 2)
          .of(morningEvening);

      expect(progress.completedAzkar, 1);
      expect(progress.doneRepetitions, 3);
      expect(progress.totalRepetitions, 104);
      expect(progress.isStarted, isTrue);
      expect(progress.isComplete, isFalse);
    });

    test('ignores counts beyond what a zikr asks for', () {
      final progress = today.withCount(27, 1, 9).of(morningEvening);

      expect(progress.doneRepetitions, 1);
    });

    test('is complete once every zikr is said in full', () {
      final progress = today
          .withCount(27, 1, 1)
          .withCount(27, 2, 3)
          .withCount(27, 3, 100)
          .of(morningEvening);

      expect(progress.isComplete, isTrue);
      expect(progress.fraction, 1);
    });
  });
}
