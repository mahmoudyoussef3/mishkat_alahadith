import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../domain/entities/ramadan_task_entity.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/toggle_daily_completion.dart';
import '../../domain/usecases/toggle_today_only_completion.dart';
import '../../domain/usecases/ensure_daily_reset.dart';
import '../../domain/usecases/compute_progress.dart';
import '../../domain/usecases/get_ramadan_calendar_use_case.dart';
import 'worship_templates.dart';
import 'dart:developer';

part 'ramadan_tasks_state.dart';

enum ViewMode { today, history, all }

class RamadanTasksCubit extends Cubit<RamadanTasksState> {
  final GetTasks _getTasks;
  final AddTask _addTask;
  final DeleteTask _deleteTask;
  final UpdateTask _updateTask;
  final ToggleDailyCompletion _toggleDaily;
  final ToggleTodayOnlyCompletion _toggleTodayOnly;
  final EnsureDailyReset _ensureDailyReset;
  final ComputeProgress _computeProgress;
  final GetRamadanCalendarUseCase _getRamadanCalendar;

  List<RamadanTaskEntity> _allTasks = [];

  int _selectedDay = 1;
  int _selectedWeek = 1;
  ViewMode _viewMode = ViewMode.today;

  RamadanTasksCubit(
    this._getTasks,
    this._addTask,
    this._deleteTask,
    this._updateTask,
    this._toggleDaily,
    this._toggleTodayOnly,
    this._ensureDailyReset,
    this._computeProgress,
    this._getRamadanCalendar,
  ) : super(RamadanTasksLoading());

  Future<void> init() async {
    emit(RamadanTasksLoading());
    try {
      final todayDay = _todayDayNumber();
      await _ensureDailyReset(todayDay);
      _allTasks = await _getTasks();
      _selectedDay = todayDay == 0 ? 1 : todayDay;
      _selectedWeek = _weekForDay(_selectedDay);
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
      final todayDay = _todayDayNumber();
      _selectedDay = todayDay == 0 ? 1 : todayDay;
      _selectedWeek = _weekForDay(_selectedDay);
    }
    _emitLoaded();
  }

  Future<void> setSelectedWeek(int week) async {
    _selectedWeek = week.clamp(1, 4);
    final range = _weekRange(_selectedWeek, _getRamadanTotalDays());
    if (_selectedDay < range.$1 || _selectedDay > range.$2) {
      _selectedDay = range.$1;
    }
    _emitLoaded();
  }

  Future<void> setSelectedDay(int day) async {
    final totalDays = _getRamadanTotalDays();
    _selectedDay = day.clamp(1, totalDays);
    _emitLoaded();
  }

  int _todayDayNumber() {
    return _getRamadanCalendar().currentDay;
  }

  int _getRamadanTotalDays() {
    return _getRamadanCalendar().totalDays;
  }

  HijriCalendar _getAdjustedHijriDate(int startOffset) {
    final hijri = HijriCalendar.now();

    if (startOffset == 0) {
      log(
        'No Ramadan start offset. Using calculated Hijri date: ${hijri.toString()}',
      );
      return hijri;
    }

    final gregorianDate = hijri.hijriToGregorian(
      hijri.hYear,
      hijri.hMonth,
      hijri.hDay,
    );
    final adjustedGregorian = gregorianDate.add(Duration(days: startOffset));
    return HijriCalendar.fromDate(adjustedGregorian);
  }

  String _hijriDateString(int todayDay, int startOffset) {
    final hijri = _getAdjustedHijriDate(startOffset);
    HijriCalendar.setLocal('ar');

    if (todayDay == 0) {
      return 'قبل رمضان';
    }

    return '${_toArabicNumerals(todayDay)} رمضان ${_toArabicNumerals(hijri.hYear)} هـ';
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

  int _weekForDay(int day) {
    if (day <= 7) return 1;
    if (day <= 14) return 2;
    if (day <= 21) return 3;
    return 4;
  }

  (int, int) _weekRange(int week, int totalDays) {
    switch (week) {
      case 1:
        return (1, 7);
      case 2:
        return (8, 14);
      case 3:
        return (15, 21);
      default:
        return (22, totalDays);
    }
  }

  void _emitLoaded() {
    final calendar = _getRamadanCalendar();
    final todayDay = calendar.currentDay;
    final totalDays = calendar.totalDays;
    final range = _weekRange(_selectedWeek, totalDays);
    final dayForProgress =
        _viewMode == ViewMode.history ? _selectedDay : todayDay;
    final progress = _computeProgress(
      tasks: _allTasks,
      day: dayForProgress,
      weekStart: range.$1,
      weekEnd: range.$2,
      totalDays: totalDays,
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
        hijriDateString: _hijriDateString(todayDay, calendar.startOffset),
        gregorianDateString: _gregorianDateString(),
        totalDays: totalDays,
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

  List<WorshipSection> _availableSuggestions() {
    final existingTitles = _allTasks.map((t) => t.title).toSet();
    return kWorshipSections
        .map((s) => s.withoutTitles(existingTitles))
        .where((s) => s.items.isNotEmpty)
        .toList();
  }
}
