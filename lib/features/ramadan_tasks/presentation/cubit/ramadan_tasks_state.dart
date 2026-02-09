part of 'ramadan_tasks_cubit.dart';

abstract class RamadanTasksState {}

class RamadanTasksLoading extends RamadanTasksState {}

class RamadanTasksError extends RamadanTasksState {
  final String message;
  RamadanTasksError(this.message);
}


class RamadanTasksLoaded extends RamadanTasksState {
  final List<RamadanTaskEntity> allTasks;
  final List<RamadanTaskEntity> filteredTasks;
  final int todayDay;
  final int selectedDay;
  final int selectedWeek;
  final int weekStart;
  final int weekEnd;
  final ViewMode viewMode;
  final double dailyPercent;
  final double overallPercent;
  final double weeklyPercent;
  final int dailyCompleted;
  final int dailyTotal;
  final String? motivationalText;
  final String hijriDateString;
  final String gregorianDateString;

  RamadanTasksLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.todayDay,
    required this.selectedDay,
    required this.selectedWeek,
    required this.weekStart,
    required this.weekEnd,
    required this.viewMode,
    required this.dailyPercent,
    required this.overallPercent,
    required this.weeklyPercent,
    required this.dailyCompleted,
    required this.dailyTotal,
    this.motivationalText,
    required this.hijriDateString,
    required this.gregorianDateString,
  });

  bool get isReadOnly => viewMode == ViewMode.history;

  int get displayDay => viewMode == ViewMode.history ? selectedDay : todayDay;
}
