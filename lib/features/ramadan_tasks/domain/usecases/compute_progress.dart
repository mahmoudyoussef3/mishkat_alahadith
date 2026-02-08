import '../entities/ramadan_task_entity.dart';

/// Result of progress computation for Ramadan tasks.
///
/// All values are 0.0 – 1.0 (percentage as fraction).
class ProgressResult {
  final double dailyPercent;
  final double monthlyPercent;
  final double weeklyPercent;

  /// How many daily tasks were completed on [day].
  final int dailyCompleted;
  final int dailyTotal;

  const ProgressResult({
    required this.dailyPercent,
    required this.monthlyPercent,
    required this.weeklyPercent,
    required this.dailyCompleted,
    required this.dailyTotal,
  });
}

/// Pure use-case that computes progress from a list of tasks.
///
/// Progress formulas:
/// - Daily  : completedDailyToday / totalDailyTasks
/// - Monthly: (completedDailySlots + completedMonthlyTasks) /
///            (dailyTasksCount * daysSoFar + monthlyTasksCount)
///   → This avoids the "30× daily" denominator that made progress always ≈0%.
/// - Weekly : daily completions within [weekStart..weekEnd] / (dailyCount × weekDays)
class ComputeProgress {
  ProgressResult call({
    required List<RamadanTaskEntity> tasks,
    required int day,
    required int weekStart,
    required int weekEnd,
  }) {
    final dailyTasks = tasks.where((t) => t.type == TaskType.daily).toList();
    final monthlyTasks =
        tasks.where((t) => t.type == TaskType.monthly).toList();

    // ── Daily progress (for the specific day) ──
    final dailyCompleted =
        dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final dailyPercent =
        dailyTasks.isEmpty ? 0.0 : dailyCompleted / dailyTasks.length;

    // ── Overall Ramadan progress ──
    // Use daysSoFar (1..day) instead of 30 so progress feels achievable early on.
    final daysSoFar = day.clamp(1, 30);
    final totalSlots = (daysSoFar * dailyTasks.length) + monthlyTasks.length;
    int completedSlots = 0;
    for (final t in dailyTasks) {
      // Only count completions up to daysSoFar
      completedSlots += t.completedDays.where((d) => d <= daysSoFar).length;
    }
    for (final t in monthlyTasks) {
      if (t.completedDays.isNotEmpty) completedSlots += 1;
    }
    final monthlyPercent = totalSlots == 0 ? 0.0 : completedSlots / totalSlots;

    // ── Weekly progress ──
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
      monthlyPercent: monthlyPercent.clamp(0.0, 1.0),
      weeklyPercent: weeklyPercent.clamp(0.0, 1.0),
      dailyCompleted: dailyCompleted,
      dailyTotal: dailyTasks.length,
    );
  }
}
