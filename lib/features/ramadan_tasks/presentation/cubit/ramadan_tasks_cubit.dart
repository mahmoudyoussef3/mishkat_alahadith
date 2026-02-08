import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
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

/// View modes for the Ramadan tasks screen.
///
/// - [today]: shows tasks for today (daily + todayOnly for this day). Editable.
/// - [history]: read-only view of any past day. Day selector visible.
/// - [all]: shows every task regardless of status. Editable.
enum ViewMode { today, history, all }

/// Manages all Ramadan tasks state: loading, filtering, selection, progress.
class RamadanTasksCubit extends Cubit<RamadanTasksState> {
  final RamadanTasksRepository _repo;
  late final GetTasks _getTasks;
  late final AddTask _addTask;
  late final DeleteTask _deleteTask;
  late final ToggleDailyCompletion _toggleDaily;
  late final ToggleTodayOnlyCompletion _toggleTodayOnly;
  late final EnsureDailyReset _ensureDailyReset;
  final _computeProgress = ComputeProgress();

  // Cached full task list (unfiltered) for fast re-filtering without I/O.
  List<RamadanTaskEntity> _allTasks = [];

  // Selection state kept in the cubit so it survives rebuilds.
  int _selectedDay = 1;
  int _selectedWeek = 1; // 1..4
  ViewMode _viewMode = ViewMode.today;

  RamadanTasksCubit(this._repo) : super(RamadanTasksLoading()) {
    _getTasks = GetTasks(_repo);
    _addTask = AddTask(_repo);
    _deleteTask = DeleteTask(_repo);
    _toggleDaily = ToggleDailyCompletion(_repo);
    _toggleTodayOnly = ToggleTodayOnlyCompletion(_repo);
    _ensureDailyReset = EnsureDailyReset(_repo);
  }

  // ─── Public API ────────────────────────────────────────────

  /// Initial load. Call once when the screen is created.
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

  Future<void> toggleDaily(String id) async {
    final day = _todayDayNumber();
    await _toggleDaily(id: id, day: day);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  Future<void> toggleTodayOnly(String id) async {
    final day = _todayDayNumber();
    await _toggleTodayOnly(id: id, day: day);
    _allTasks = await _getTasks();
    _emitLoaded();
  }

  /// Switch between Today / History / All.
  Future<void> setViewMode(ViewMode mode) async {
    _viewMode = mode;
    // When switching to history, default to today's day so the user
    // starts from a meaningful reference point.
    if (mode == ViewMode.history) {
      _selectedDay = _todayDayNumber();
      _selectedWeek = _weekForDay(_selectedDay);
    }
    _emitLoaded();
  }

  /// Select a week (1..4). Clamps the selected day into the week range.
  Future<void> setSelectedWeek(int week) async {
    _selectedWeek = week.clamp(1, 4);
    final range = _weekRange(_selectedWeek);
    // Keep selectedDay inside the new week bounds.
    if (_selectedDay < range.$1 || _selectedDay > range.$2) {
      _selectedDay = range.$1;
    }
    _emitLoaded();
  }

  /// Select a specific day (1..30) in History view.
  Future<void> setSelectedDay(int day) async {
    _selectedDay = day.clamp(1, 30);
    _emitLoaded();
  }

  // ─── Internal helpers ──────────────────────────────────────

  /// Returns the current Hijri day of the month (Ramadan day 1..30).
  int _todayDayNumber() {
    final hijri = HijriCalendar.now();
    return hijri.hDay.clamp(1, 30);
  }

  /// Formatted Hijri date string, e.g. "١٥ رمضان ١٤٤٧ هـ".
  String _hijriDateString() {
    final hijri = HijriCalendar.now();
    HijriCalendar.setLocal('ar');
    return '${_toArabicNumerals(hijri.hDay)} ${hijri.getLongMonthName()} ${_toArabicNumerals(hijri.hYear)} هـ';
  }

  /// Formatted Gregorian date string, e.g. "٨ فبراير ٢٠٢٦ م".
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

  /// Converts an integer to Arabic-Indic numerals string.
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

  /// Returns (start, end) day numbers for a given week index.
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

  /// Emits a new [RamadanTasksLoaded] from the cached [_allTasks].
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

  /// Filtering logic (pure function — no I/O).
  ///
  /// - Today: all daily tasks + todayOnly tasks created for today.
  /// - History: all daily tasks + todayOnly tasks for that selected day.
  /// - All: all tasks.
  List<RamadanTaskEntity> _filterTasks(
    List<RamadanTaskEntity> tasks,
    int todayDay,
  ) {
    switch (_viewMode) {
      case ViewMode.today:
        return tasks.where((t) {
          if (t.type == TaskType.daily) return true;
          // Show todayOnly tasks only on their specific day
          return t.createdForDay == todayDay;
        }).toList();
      case ViewMode.history:
        return tasks.where((t) {
          if (t.type == TaskType.daily) return true;
          // Show todayOnly tasks for the selected day
          return t.createdForDay == _selectedDay;
        }).toList();
      case ViewMode.all:
        return List.unmodifiable(tasks);
    }
  }
}
