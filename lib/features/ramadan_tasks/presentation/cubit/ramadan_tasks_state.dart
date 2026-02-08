part of 'ramadan_tasks_cubit.dart';

abstract class RamadanTasksState {}

class RamadanTasksLoading extends RamadanTasksState {}

class RamadanTasksError extends RamadanTasksState {
  final String message;
  RamadanTasksError(this.message);
}

class RamadanTasksLoaded extends RamadanTasksState {
  final List<RamadanTaskEntity> tasks;
  final int todayDay;
  final double dailyPercent;
  final double monthlyPercent;
  final double weeklyPercent;
  final String? motivationalText;

  RamadanTasksLoaded({
    required this.tasks,
    required this.todayDay,
    required this.dailyPercent,
    required this.monthlyPercent,
    required this.weeklyPercent,
    this.motivationalText,
  });
}
