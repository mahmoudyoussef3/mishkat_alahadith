import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/models/zekr_item.dart';
import 'package:mishkat_almasabih/features/daily_zekr/data/repo/zekr_repository.dart';
import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/asr_method_preference.dart';

part 'daily_zekr_state.dart';

class DailyZekrCubit extends Cubit<DailyZekrState> {
  final ZekrRepository _repo;

  DailyZekrCubit(this._repo) : super(DailyZekrInitial());

  /// Load persisted states and ensure notifications reflect current status.
  Future<void> init() async {
    emit(DailyZekrLoading());
    try {
      final items = await _repo.loadAll();
      // Sync notifications for each section
      for (final item in items) {
        await _syncNotifications(item);
      }
      emit(DailyZekrLoaded(items));
    } catch (e) {
      emit(DailyZekrError('حدث خطأ أثناء تحميل البيانات')); // Arabic error
    }
  }

  /// Toggle a section, persist the change, and schedule/cancel notifications.
  Future<void> toggle(ZekrSection section) async {
    final current = state;
    if (current is! DailyZekrLoaded) return;

    final items = current.items
        .map((it) {
          if (it.section == section) return it.copyWith(checked: !it.checked);
          return it;
        })
        .toList(growable: false);

    // Persist and sync notifications for the toggled item
    final updatedItem = items.firstWhere((it) => it.section == section);
    await _repo.setChecked(section, updatedItem.checked);
    await _syncNotifications(updatedItem);

    emit(DailyZekrLoaded(items));
  }

  Future<void> _syncNotifications(ZekrItem item) async {
    // 1) Respect user's notification preferences
    final enabledByUser = await _isUserPrefEnabled(item.section);
    if (!enabledByUser) {
      await LocalNotification.cancelReminder(item.section.notificationId);
      return;
    }

    // If user marked as done, never remind.
    if (item.checked) {
      await LocalNotification.cancelReminder(item.section.notificationId);
      return;
    }

    // Respect availability windows for morning/evening adhkar.
    final now = DateTime.now();
    final isAvailable = await _isAvailableNow(item.section, now);

    if (!isAvailable) {
      // Outside valid window: ensure no active periodic reminder.
      await LocalNotification.cancelReminder(item.section.notificationId);
      return;
    }

    // Within valid window: schedule periodic reminder (every minute for testing).
    await LocalNotification.scheduleHourlyReminder(
      id: item.section.notificationId,
      channelId: item.section.channelId,
      channelName: item.section.channelName,
      title: item.section.title,
      body: item.section.reminderBody,
      payload: item.section.name,
      everyMinute: true, // For testing purposes
    );
  }

  /// Map profile screen preference keys to sections and read stored value.
  Future<bool> _isUserPrefEnabled(ZekrSection section) async {
    final prefs = await SharedPreferences.getInstance();
    switch (section) {
      case ZekrSection.hadithDaily:
        return prefs.getBool('daily_hadith_notification') ?? true;
      case ZekrSection.morningAdhkar:
      case ZekrSection.eveningAdhkar:
        return prefs.getBool('azkar_notification') ?? false;
      case ZekrSection.dailyWard:
        return prefs.getBool('werd_notification') ?? false;
    }
  }

  // Determines if a section is currently "available" based on prayer times.
  Future<bool> _isAvailableNow(ZekrSection section, DateTime now) async {
    if (section != ZekrSection.morningAdhkar &&
        section != ZekrSection.eveningAdhkar) {
      return true; // Always available for others
    }

    final asrMethod = await AsrMethodPreference.load();
    final calc = PrayerCalculator(
      latitude: 30.0444,
      longitude: 31.2357,
      timezone: 2.0,
      asrMethod: asrMethod,
    );
    final dayStart = DateTime(now.year, now.month, now.day);
    final today = calc.calculate(dayStart);
    final yesterday = calc.calculate(
      dayStart.subtract(const Duration(days: 1)),
    );
    final tomorrow = calc.calculate(dayStart.add(const Duration(days: 1)));

    late final DateTime start;
    late final DateTime end;

    if (section == ZekrSection.morningAdhkar) {
      // Morning: from Fajr to Dhuhr
      start = today.fajr;
      end = today.dhuhr;
    } else {
      // Evening: from Asr to next Fajr (spanning midnight if needed)
      final isAfterMidnightBeforeFajr = now.isBefore(today.fajr);
      if (isAfterMidnightBeforeFajr) {
        start = yesterday.asr;
        end = today.fajr;
      } else {
        start = today.asr;
        end = tomorrow.fajr;
      }
    }

    return now.isAfter(start) && now.isBefore(end);
  }
}
