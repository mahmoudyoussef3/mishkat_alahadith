import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/prayer_times_reminder_service.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/asr_method_preference.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesReminderService _reminderService;

  PrayerTimesCubit(this._reminderService) : super(PrayerTimesInitial());

  late PrayerCalculator _calculator;
  late AsrMethod _asrMethod;
  Timer? _ticker;

  Future<void> init() async {
    emit(PrayerTimesLoading());
    try {
      _asrMethod = await AsrMethodPreference.load();

      _calculator = PrayerCalculator(
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 2.0,
        asrMethod: _asrMethod,
      );

      final date = DateTime.now();
      final times = _calculator.calculate(date);
      final loaded = _buildLoaded(date, times);
      emit(loaded);

      final tomorrowTimes = _calculator.calculate(
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1)),
      );
      unawaited(
        _reminderService.syncPrayerReminders(
          todayTimes: times,
          tomorrowTimes: tomorrowTimes,
          now: date,
        ),
      );

      _startTicker();
    } catch (e) {
      emit(PrayerTimesError('تعذر حساب مواقيت الصلاة'));
    }
  }

  /// Change the Asr juristic method, persist it, and recalculate.
  Future<void> changeAsrMethod(AsrMethod method) async {
    if (method == _asrMethod) return;
    _asrMethod = method;
    await AsrMethodPreference.save(method);

    _calculator = PrayerCalculator(
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 2.0,
      asrMethod: _asrMethod,
    );

    final date = DateTime.now();
    final times = _calculator.calculate(date);
    emit(_buildLoaded(date, times));

    final tomorrowTimes = _calculator.calculate(
      DateTime(date.year, date.month, date.day).add(const Duration(days: 1)),
    );
    unawaited(
      _reminderService.syncPrayerReminders(
        todayTimes: times,
        tomorrowTimes: tomorrowTimes,
        now: date,
      ),
    );
  }

  /// The currently active Asr method.
  AsrMethod get currentAsrMethod => _asrMethod;

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is! PrayerTimesLoaded) return;

      // Recalculate at day change
      final now = DateTime.now();
      if (!_isSameDay(now, current.date)) {
        final newTimes = _calculator.calculate(now);
        emit(_buildLoaded(now, newTimes));

        final tomorrow = DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1));
        final tomorrowTimes = _calculator.calculate(tomorrow);
        unawaited(
          _reminderService.syncPrayerReminders(
            todayTimes: newTimes,
            tomorrowTimes: tomorrowTimes,
            now: now,
          ),
        );
        return;
      }

      final remaining = current.times.getTimeRemaining(now);
      final nextName = current.times.getNextPrayerName(now);
      final label = _arabicLabel(nextName);
      final nextTime = current.times.getNextPrayer(now);
      emit(
        current.copyWith(
          remaining: remaining,
          nextPrayerLabel: label,
          nextPrayerTime: nextTime,
        ),
      );
    });
  }

  PrayerTimesLoaded _buildLoaded(DateTime date, PrayerTimes times) {
    final now = DateTime.now();
    return PrayerTimesLoaded(
      date: DateTime(date.year, date.month, date.day),
      times: times,
      nextPrayerLabel: _arabicLabel(times.getNextPrayerName(now)),
      nextPrayerTime: times.getNextPrayer(now),
      remaining: times.getTimeRemaining(now),
      asrMethod: _asrMethod,
    );
  }

  String? _arabicLabel(PrayerName? name) {
    switch (name) {
      case PrayerName.fajr:
        return 'الفجر';
      case PrayerName.dhuhr:
        return 'الظهر';
      case PrayerName.asr:
        return 'العصر';
      case PrayerName.maghrib:
        return 'المغرب';
      case PrayerName.isha:
        return 'العشاء';
      default:
        return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
