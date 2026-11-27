import 'azkar_category.dart';

/// What the reader counted on one day. Counting starts afresh every day, so
/// the morning remembrances are there to be said again tomorrow.
class AzkarDayProgress {
  /// Midnight at the start of the day, in local time.
  final DateTime day;

  /// Chapter id → zikr id → times said so far.
  final Map<int, Map<int, int>> counts;

  const AzkarDayProgress({required this.day, this.counts = const {}});

  factory AzkarDayProgress.emptyOn(DateTime moment) =>
      AzkarDayProgress(day: dayOf(moment));

  /// [stored] when it is from the day of [now], otherwise a fresh day.
  factory AzkarDayProgress.currentOf(AzkarDayProgress? stored, DateTime now) =>
      stored != null && stored.isOn(now)
          ? stored
          : AzkarDayProgress.emptyOn(now);

  static DateTime dayOf(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  bool isOn(DateTime moment) => day == dayOf(moment);

  Map<int, int> countsFor(int categoryId) => counts[categoryId] ?? const {};

  int countOf(int categoryId, int zikrId) => counts[categoryId]?[zikrId] ?? 0;

  /// Records that the zikr has been said [count] times; zero forgets it.
  AzkarDayProgress withCount(int categoryId, int zikrId, int count) {
    final category = {...countsFor(categoryId)};
    if (count > 0) {
      category[zikrId] = count;
    } else {
      category.remove(zikrId);
    }
    final next = {...counts};
    if (category.isEmpty) {
      next.remove(categoryId);
    } else {
      next[categoryId] = Map.unmodifiable(category);
    }
    return AzkarDayProgress(day: day, counts: Map.unmodifiable(next));
  }

  AzkarDayProgress withoutCategory(int categoryId) {
    if (!counts.containsKey(categoryId)) return this;
    return AzkarDayProgress(
      day: day,
      counts: Map.unmodifiable({...counts}..remove(categoryId)),
    );
  }

  AzkarCategoryProgress of(AzkarCategory category) =>
      AzkarCategoryProgress.of(category, countsFor(category.id));
}

/// How far through one chapter the reader is today.
class AzkarCategoryProgress {
  /// Azkar said as many times as asked.
  final int completedAzkar;
  final int totalAzkar;
  final int doneRepetitions;
  final int totalRepetitions;

  const AzkarCategoryProgress({
    required this.completedAzkar,
    required this.totalAzkar,
    required this.doneRepetitions,
    required this.totalRepetitions,
  });

  /// Counts beyond what a zikr asks for, or for azkar no longer in the
  /// chapter, are ignored.
  factory AzkarCategoryProgress.of(
    AzkarCategory category,
    Map<int, int> counts,
  ) {
    var completed = 0;
    var done = 0;
    for (final zikr in category.azkar) {
      final said = (counts[zikr.id] ?? 0).clamp(0, zikr.count);
      done += said;
      if (said == zikr.count) completed++;
    }
    return AzkarCategoryProgress(
      completedAzkar: completed,
      totalAzkar: category.azkar.length,
      doneRepetitions: done,
      totalRepetitions: category.totalRepetitions,
    );
  }

  double get fraction =>
      totalRepetitions == 0 ? 0 : doneRepetitions / totalRepetitions;

  bool get isStarted => doneRepetitions > 0;

  bool get isComplete => totalAzkar > 0 && completedAzkar == totalAzkar;
}
