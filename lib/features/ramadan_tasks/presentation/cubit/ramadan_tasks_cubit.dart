import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../../domain/repositories/ramadan_tasks_repository.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_daily_completion.dart';
import '../../domain/usecases/set_monthly_completed.dart';
import '../../domain/usecases/ensure_daily_reset.dart';
import '../../domain/usecases/compute_progress.dart';

part 'ramadan_tasks_state.dart';

/// View modes for Ramadan tasks UI
enum ViewMode { today, history, all }

class RamadanTasksCubit extends Cubit<RamadanTasksState> {
  final RamadanTasksRepository _repo;
  late final GetTasks _getTasks;
  late final AddTask _addTask;
  late final DeleteTask _deleteTask;
  late final ToggleDailyCompletion _toggleDaily;
  late final SetMonthlyCompleted _setMonthly;
  late final EnsureDailyReset _ensureDailyReset;
  final _computeProgress = ComputeProgress();

  // Selection state
  int _selectedDay = DateTime.now().day.clamp(1, 30);
  int _weekStart = 1;
  int _weekEnd = 7;
  ViewMode _viewMode = ViewMode.today;

  RamadanTasksCubit(this._repo) : super(RamadanTasksLoading()) {
    _getTasks = GetTasks(_repo);
    _addTask = AddTask(_repo);
    _deleteTask = DeleteTask(_repo);
    _toggleDaily = ToggleDailyCompletion(_repo);
    _setMonthly = SetMonthlyCompleted(_repo);
    _ensureDailyReset = EnsureDailyReset(_repo);
  }

  Future<void> init() async {
    emit(RamadanTasksLoading());
    final todayDay = _todayDayNumber();
    await _ensureDailyReset(todayDay);
    final tasks = await _getTasks();
    final initialRange = _weekRange(todayDay);
    _weekStart = initialRange.$1;
    _weekEnd = initialRange.$2;
    _selectedDay = todayDay;
    emit(_buildLoadedState(tasks: tasks, todayDay: todayDay));
  }

  Future<void> addNewTask({required String title, required TaskType type}) async {
    final newTask = RamadanTaskEntity(id: '', title: title.trim(), type: type, completedDays: {});
    await _addTask(newTask);
    await init();
  }

  Future<void> deleteById(String id) async {
    await _deleteTask(id);
    await init();
  }

  Future<void> toggleDaily(String id) async {
    final day = _todayDayNumber();
    await _toggleDaily(id: id, day: day);
    await _reloadPreservingSelection();
  }

  Future<void> setMonthly(String id, bool completed) async {
    final day = _todayDayNumber();
    await _setMonthly(id: id, completed: completed, day: day);
    await _reloadPreservingSelection();
  }

  Future<void> _reloadPreservingSelection() async {
    final todayDay = _todayDayNumber();
    final tasks = await _getTasks();
    emit(_buildLoadedState(tasks: tasks, todayDay: todayDay));
  }

  // Filtering & selection API
  void setViewMode(ViewMode mode) async {
    _viewMode = mode;
    await _reloadPreservingSelection();
  }

  void setWeekIndex(int index) async {
    // index: 1..4
    switch (index) {
      case 1:
        _weekStart = 1;
        _weekEnd = 7;
        break;
      case 2:
        _weekStart = 8;
        _weekEnd = 14;
        break;
      case 3:
        _weekStart = 15;
        _weekEnd = 21;
        break;
      default:
        _weekStart = 22;
        _weekEnd = 30;
    }
    // Clamp selected day into week range for history view UX
    _selectedDay = _selectedDay.clamp(_weekStart, _weekEnd);
    await _reloadPreservingSelection();
  }

  void setSelectedDay(int day) async {
    _selectedDay = day.clamp(1, 30);
    await _reloadPreservingSelection();
  }

  int _todayDayNumber() {
    // Simplified: clamp day-of-month to 1..30
    final d = DateTime.now().day;
    return d.clamp(1, 30);
  }

  (int, int) _weekRange(int day) {
    if (day <= 7) return (1, 7);
    if (day <= 14) return (8, 14);
    if (day <= 21) return (15, 21);
    return (22, 30);
  }

  RamadanTasksLoaded _buildLoadedState({required List<RamadanTaskEntity> tasks, required int todayDay}) {
    final filtered = _filterTasks(tasks: tasks, todayDay: todayDay);
    final dayForDailyProgress = _viewMode == ViewMode.history ? _selectedDay : todayDay;
    final progress = _computeProgress(tasks: tasks, day: dayForDailyProgress, weekStart: _weekStart, weekEnd: _weekEnd);
    return RamadanTasksLoaded(
      tasks: filtered,
      todayDay: todayDay,
      selectedDay: _selectedDay,
      weekStart: _weekStart,
      weekEnd: _weekEnd,
      viewMode: _viewMode,
      dailyPercent: progress.dailyPercent,
      monthlyPercent: progress.monthlyPercent,
      weeklyPercent: progress.weeklyPercent,
      motivationalText: progress.dailyPercent >= 1.0 ? 'ما شاء الله! أنجزت مهامك اليومية بالكامل 👏' : null,
    );
  }

  List<RamadanTaskEntity> _filterTasks({required List<RamadanTaskEntity> tasks, required int todayDay}) {
    switch (_viewMode) {
      case ViewMode.today:
        // Show all daily tasks; monthly tasks until first completion
        return tasks.where((t) => t.type == TaskType.daily || (t.type == TaskType.monthly && t.completedDays.isEmpty)).toList();
      case ViewMode.history:
        // Read-only: show all tasks for inspection
        return tasks;
      case ViewMode.all:
        return tasks;
    }
  }
}
