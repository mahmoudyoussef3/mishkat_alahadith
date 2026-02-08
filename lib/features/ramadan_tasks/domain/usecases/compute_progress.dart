import '../entities/ramadan_task_entity.dart';

/// Result of progress computation for Ramadan tasks.
///
/// All values are 0.0 – 1.0 (percentage as fraction).
class ProgressResult {
  final double dailyPercent;
  final double overallPercent;
  final double weeklyPercent;

  /// How many tasks (daily + todayOnly) were completed on [day].
  final int dailyCompleted;
  final int dailyTotal;

  const ProgressResult({
    required this.dailyPercent,
    required this.overallPercent,
    required this.weeklyPercent,
    required this.dailyCompleted,
    required this.dailyTotal,
  });
}

/// Pure use-case that computes progress from a list of tasks.
///
/// Progress formulas:
/// - Daily  : (completedDaily + completedTodayOnly) / (totalDaily + todayOnlyForDay)
///   on the specific day being viewed.
/// - Overall: total daily completions across daysSoFar / (dailyCount × daysSoFar + todayOnlyCount)
/// - Weekly : daily completions within [weekStart..weekEnd] / (dailyCount × weekDays)
class ComputeProgress {
  ProgressResult call({
    required List<RamadanTaskEntity> tasks,
    required int day,
    required int weekStart,
    required int weekEnd,
  }) {
    final dailyTasks = tasks.where((t) => t.type == TaskType.daily).toList();
    final todayOnlyForDay =
        tasks
            .where(
              (t) => t.type == TaskType.todayOnly && t.createdForDay == day,
            )
            .toList();
    final allTodayOnly =
        tasks.where((t) => t.type == TaskType.todayOnly).toList();

    // ── Daily progress (for the specific day) ──
    final dailyCompletedCount =
        dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final todayOnlyCompletedCount =
        todayOnlyForDay.where((t) => t.completedDays.contains(day)).length;
    final totalForDay = dailyTasks.length + todayOnlyForDay.length;
    final completedForDay = dailyCompletedCount + todayOnlyCompletedCount;
    final dailyPercent = totalForDay == 0 ? 0.0 : completedForDay / totalForDay;

    // ── Overall Ramadan progress ──
    final daysSoFar = day.clamp(1, 30);
    final totalSlots = (daysSoFar * dailyTasks.length) + allTodayOnly.length;
    int completedSlots = 0;
    for (final t in dailyTasks) {
      completedSlots += t.completedDays.where((d) => d <= daysSoFar).length;
    }
    for (final t in allTodayOnly) {
      if (t.completedDays.contains(t.createdForDay)) completedSlots += 1;
    }
    final overallPercent = totalSlots == 0 ? 0.0 : completedSlots / totalSlots;

    // ── Weekly progress (daily tasks only) ──
    final weekDays = (weekEnd - weekStart + 1).clamp(1, 30);
    final totalWeeklySlots = dailyTasks.length * weekDays;
    int weeklyCompleted = 0;
    for (final t in dailyTasks) {
      weeklyCompleted +=
          t.completedDays.where((d) => d >= weekStart && d <= weekEnd).length;
    }
    final weeklyPercent =
        totalWeeklySlots == 0 ? 0.0 : weeklyCompleted / totalWeeklySlots;

    return ProgressResult(
      dailyPercent: dailyPercent.clamp(0.0, 1.0),
      overallPercent: overallPercent.clamp(0.0, 1.0),
      weeklyPercent: weeklyPercent.clamp(0.0, 1.0),
      dailyCompleted: completedForDay,
      dailyTotal: totalForDay,
    );
  }
}
