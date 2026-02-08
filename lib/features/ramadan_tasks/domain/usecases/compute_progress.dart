import '../entities/ramadan_task_entity.dart';

/// Computes progress values for daily, monthly, and weekly (optional) scopes.
class ProgressResult {
  final double dailyPercent; // 0..1
  final double monthlyPercent; // 0..1 (overall Ramadan progress)
  final double weeklyPercent; // 0..1
  ProgressResult({
    required this.dailyPercent,
    required this.monthlyPercent,
    required this.weeklyPercent,
  });
}

class ComputeProgress {
  /// day: today's day number (1..30)
  /// weekDays: number of days in the current week (UI grouping: 7, 8, etc.)
  /// weekRange: inclusive range of days for the current week (e.g., 1..7)
  ProgressResult call({
    required List<RamadanTaskEntity> tasks,
    required int day,
    required int weekStart,
    required int weekEnd,
  }) {
    final dailyTasks = tasks.where((t) => t.type == TaskType.daily).toList();
    final monthlyTasks =
        tasks.where((t) => t.type == TaskType.monthly).toList();

    // Daily progress: count of daily tasks completed today over total daily tasks
    final dailyCompleted =
        dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final dailyPercent =
        dailyTasks.isEmpty ? 0.0 : dailyCompleted / dailyTasks.length;

    // Overall Ramadan progress: completed "slots" across Ramadan divided by total possible slots
    // Total possible slots: (30 * dailyTasksCount) + monthlyTasksCount
    final totalSlots = (30 * dailyTasks.length) + monthlyTasks.length;
    int completedSlots = 0;
    // For daily tasks: each day completed counts as one slot
    for (final t in dailyTasks) {
      completedSlots += t.completedDays.length;
    }
    // For monthly tasks: if they are completed on any day, count 1 slot
    for (final t in monthlyTasks) {
      if (t.completedDays.isNotEmpty) completedSlots += 1;
    }
    final monthlyPercent = totalSlots == 0 ? 0.0 : completedSlots / totalSlots;

    // Weekly progress: daily completions within the week divided by dailyTasksCount * weekDays
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
    );
  }
}
