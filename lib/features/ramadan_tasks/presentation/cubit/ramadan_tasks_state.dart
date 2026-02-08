part of 'ramadan_tasks_cubit.dart';

/// Base class for all Ramadan tasks states.
abstract class RamadanTasksState {}

/// Emitted while tasks are being loaded from storage.
class RamadanTasksLoading extends RamadanTasksState {}

/// Emitted when an error occurs during loading.
class RamadanTasksError extends RamadanTasksState {
  final String message;
  RamadanTasksError(this.message);
}

/// Main loaded state carrying all data the UI needs.
///
/// [allTasks] — full unfiltered list (used by progress widgets).
/// [filteredTasks] — tasks filtered by the current [viewMode].
/// [todayDay] — Ramadan day number (1..30) based on current date.
/// [selectedDay] — which day the user is inspecting in History view.
/// [selectedWeek] — which week tab is active (1..4).
/// [weekStart] / [weekEnd] — day range for the selected week.
/// [dailyCompleted] / [dailyTotal] — counters for the summary card.
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

  /// Whether the user can interact (toggle/delete) with tasks.
  bool get isReadOnly => viewMode == ViewMode.history;

  /// The day number to show completion status for in the task list.
  int get displayDay => viewMode == ViewMode.history ? selectedDay : todayDay;
}
