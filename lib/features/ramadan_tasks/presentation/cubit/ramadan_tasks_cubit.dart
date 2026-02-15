import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../../domain/repositories/ramadan_tasks_repository.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/toggle_daily_completion.dart';
import '../../domain/usecases/set_monthly_completed.dart';
import '../../domain/usecases/ensure_daily_reset.dart';
import '../../domain/usecases/compute_progress.dart';
import '../../domain/worship_templates.dart';

part 'ramadan_tasks_state.dart';

enum ViewMode { today, history, all }

class RamadanTasksCubit extends Cubit<RamadanTasksState> {
  final RamadanTasksRepository _repo;
  late final GetTasks _getTasks;
  late final AddTask _addTask;
  late final DeleteTask _deleteTask;
  late final UpdateTask _updateTask;
  late final ToggleDailyCompletion _toggleDaily;
  late final ToggleTodayOnlyCompletion _toggleTodayOnly;
  late final EnsureDailyReset _ensureDailyReset;
  final _computeProgress = ComputeProgress();

  List<RamadanTaskEntity> _allTasks = [];

  int _selectedDay = 1;
  int _selectedWeek = 1;
  ViewMode _viewMode = ViewMode.today;

  RamadanTasksCubit(this._repo) : super(RamadanTasksLoading()) {
    _getTasks = GetTasks(_repo);
    _addTask = AddTask(_repo);
    _deleteTask = DeleteTask(_repo);
    _updateTask = UpdateTask(_repo);
    _toggleDaily = ToggleDailyCompletion(_repo);
    _toggleTodayOnly = ToggleTodayOnlyCompletion(_repo);
    _ensureDailyReset = EnsureDailyReset(_repo);
  }

  Future<void> init() async {
    emit(RamadanTasksLoading());
    try {
      final todayDay = _todayDayNumber();
      await _ensureDailyReset(todayDay);
      _allTasks = await _getTasks();
      _selectedDay = todayDay;
      _selectedWeek = _weekForDay(todayDay);
      _emitLoaded();
    } catch (e) {
      emit(RamadanTasksError('حدث خطأ أثناء تحميل المهام'));
    }
  }

  Future<void> addNewTask({
    required String title,
    String description = '',
    required TaskType type,
  }) async {
    final todayDay = _todayDayNumber();
    final newTask = RamadanTaskEntity(
      id: '',
      title: title.trim(),
      description: description.trim(),
      type: type,
      completedDays: const {},
      createdForDay: type == TaskType.todayOnly ? todayDay : 0,
    );
    await _addTask(newTask);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> deleteById(String id) async {
    await _deleteTask(id);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> editTask({
    required String id,
    required String title,
    String description = '',
  }) async {
    final existing = _allTasks.firstWhere((t) => t.id == id);
    final updated = existing.copyWith(
      title: title.trim(),
      description: description.trim(),
    );
    await _updateTask(updated);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> toggleDaily(String id, {int? day}) async {
    final d = day ?? _todayDayNumber();
    await _toggleDaily(id: id, day: d);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> toggleTodayOnly(String id, {int? day}) async {
    final d = day ?? _todayDayNumber();
    await _toggleTodayOnly(id: id, day: d);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> setViewMode(ViewMode mode) async {
    _viewMode = mode;

    if (mode == ViewMode.history) {
      _selectedDay = _todayDayNumber();
      _selectedWeek = _weekForDay(_selectedDay);
    }
    _emitLoaded();
  }

  Future<void> setSelectedWeek(int week) async {
    _selectedWeek = week.clamp(1, 4);
    final range = _weekRange(_selectedWeek);
    if (_selectedDay < range.$1 || _selectedDay > range.$2) {
      _selectedDay = range.$1;
    }
    _emitLoaded();
  }

  Future<void> setSelectedDay(int day) async {
    _selectedDay = day.clamp(1, 30);
    _emitLoaded();
  }

  int _todayDayNumber() {
    final hijri = HijriCalendar.now();
    return hijri.hDay.clamp(1, 30);
  }

  String _hijriDateString() {
    final hijri = HijriCalendar.now();
    HijriCalendar.setLocal('ar');
    return '${_toArabicNumerals(hijri.hDay)} ${hijri.getLongMonthName()} ${_toArabicNumerals(hijri.hYear)} هـ';
  }

  String _gregorianDateString() {
    final now = DateTime.now();
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${_toArabicNumerals(now.day)} ${months[now.month - 1]} ${_toArabicNumerals(now.year)} م';
  }

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  /// Returns which week (1..4) a given day belongs to.
  int _weekForDay(int day) {
    if (day <= 7) return 1;
    if (day <= 14) return 2;
    if (day <= 21) return 3;
    return 4;
  }

  (int, int) _weekRange(int week) {
    switch (week) {
      case 1:
        return (1, 7);
      case 2:
        return (8, 14);
      case 3:
        return (15, 21);
      default:
        return (22, 30);
    }
  }

  void _emitLoaded() {
    final todayDay = _todayDayNumber();
    final range = _weekRange(_selectedWeek);
    final dayForProgress =
        _viewMode == ViewMode.history ? _selectedDay : todayDay;
    final progress = _computeProgress(
      tasks: _allTasks,
      day: dayForProgress,
      weekStart: range.$1,
      weekEnd: range.$2,
    );
    final filtered = _filterTasks(_allTasks, todayDay);
    final suggestions = _availableSuggestions();

    String? motivation;
    if (_viewMode == ViewMode.today &&
        progress.dailyPercent >= 1.0 &&
        progress.dailyTotal > 0) {
      motivation = 'ما شاء الله! أتممت جميع مهامك اليوم 🌟';
    }

    emit(
      RamadanTasksLoaded(
        allTasks: _allTasks,
        filteredTasks: filtered,
        availableSuggestions: suggestions,
        todayDay: todayDay,
        selectedDay: _selectedDay,
        selectedWeek: _selectedWeek,
        weekStart: range.$1,
        weekEnd: range.$2,
        viewMode: _viewMode,
        dailyPercent: progress.dailyPercent,
        overallPercent: progress.overallPercent,
        weeklyPercent: progress.weeklyPercent,
        dailyCompleted: progress.dailyCompleted,
        dailyTotal: progress.dailyTotal,
        motivationalText: motivation,
        hijriDateString: _hijriDateString(),
        gregorianDateString: _gregorianDateString(),
      ),
    );
  }

  List<RamadanTaskEntity> _filterTasks(
    List<RamadanTaskEntity> tasks,
    int todayDay,
  ) {
    switch (_viewMode) {
      case ViewMode.today:
        return tasks.where((t) {
          if (t.type == TaskType.daily) return true;
          return t.createdForDay == todayDay;
        }).toList();
      case ViewMode.history:
        return tasks.where((t) {
          if (t.type == TaskType.daily) return true;
          return t.createdForDay == _selectedDay;
        }).toList();
      case ViewMode.all:
        return List.unmodifiable(tasks);
    }
  }

  /// Returns worship sections with already-added task titles removed.
  List<WorshipSection> _availableSuggestions() {
    final existingTitles = _allTasks.map((t) => t.title).toSet();
    return kWorshipSections
        .map((s) => s.withoutTitles(existingTitles))
        .where((s) => s.items.isNotEmpty)
        .toList();
  }
}
