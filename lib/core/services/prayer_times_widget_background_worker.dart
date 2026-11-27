import 'dart:io';

import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';
import 'package:workmanager/workmanager.dart';

import '../notification/prayer_time_notification_scheduler.dart';
import 'prayer_times_home_widget_sync.dart';

class PrayerTimesWidgetBackgroundWorker {
  static const String _widgetRefreshTask = 'prayer_times_widget_refresh';
  static const String _uniqueWidgetRefreshTask =
      'prayer_times_widget_refresh_daily';

  static const String _notificationResyncTask = 'prayer_notifications_resync';
  static const String _uniqueNotificationResyncTask =
      'prayer_notifications_resync_periodic';
  static const Duration _notificationResyncFrequency = Duration(hours: 6);

  /// Keeps the daily ayah's widget data and notifications a month ahead
  /// while the app stays closed.
  static const String _dailyAyahSyncTask = 'daily_ayah_sync';
  static const String _uniqueDailyAyahSyncTask = 'daily_ayah_sync_daily';

  static Future<void> initialize() async {
    await Workmanager().initialize(prayerTimesWidgetCallbackDispatcher);

    if (!Platform.isAndroid) {
      return;
    }

    if (!await Workmanager().isScheduledByUniqueName(
      _uniqueWidgetRefreshTask,
    )) {
      await Workmanager().registerPeriodicTask(
        _uniqueWidgetRefreshTask,
        _widgetRefreshTask,
        frequency: const Duration(hours: 24),
        initialDelay: _delayUntilNextMidnight(),
      );
    }

    if (!await Workmanager().isScheduledByUniqueName(
      _uniqueNotificationResyncTask,
    )) {
      await Workmanager().registerPeriodicTask(
        _uniqueNotificationResyncTask,
        _notificationResyncTask,
        frequency: _notificationResyncFrequency,
      );
    }

    if (!await Workmanager().isScheduledByUniqueName(
      _uniqueDailyAyahSyncTask,
    )) {
      await Workmanager().registerPeriodicTask(
        _uniqueDailyAyahSyncTask,
        _dailyAyahSyncTask,
        frequency: const Duration(hours: 24),
        // The app has just synced on start; a first run now would repeat it.
        initialDelay: _delayUntilNextMidnight(),
      );
    }
  }

  static Duration _delayUntilNextMidnight() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }
}

@pragma('vm:entry-point')
void prayerTimesWidgetCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case PrayerTimesWidgetBackgroundWorker._widgetRefreshTask:
        await PrayerTimesHomeWidgetSync.refresh();
        return true;
      case PrayerTimesWidgetBackgroundWorker._notificationResyncTask:
        final result = await PrayerNotificationScheduler.refreshSchedule();
        return result.success;
      case PrayerTimesWidgetBackgroundWorker._dailyAyahSyncTask:
        setUpBackgroundGetIt();
        final result = await getIt<SyncDailyAyahUseCase>()();
        return result is ApiSuccess;
    }

    return true;
  });
}
