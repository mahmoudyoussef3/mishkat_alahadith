import '../entities/ramadan_task_entity.dart';

class ProgressResult {
  final double dailyPercent;
  final double overallPercent;
  final double weeklyPercent;

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

    final dailyCompletedCount =
        dailyTasks.where((t) => t.completedDays.contains(day)).length;
    final todayOnlyCompletedCount =
        todayOnlyForDay.where((t) => t.completedDays.contains(day)).length;
    final totalForDay = dailyTasks.length + todayOnlyForDay.length;
    final completedForDay = dailyCompletedCount + todayOnlyCompletedCount;
    final dailyPercent = totalForDay == 0 ? 0.0 : completedForDay / totalForDay;

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
