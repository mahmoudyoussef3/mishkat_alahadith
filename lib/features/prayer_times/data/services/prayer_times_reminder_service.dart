import 'dart:developer';
import 'package:mishkat_almasabih/core/notification/notification_helper.dart';

/// Signature for the function that actually schedules a single notification.
/// Defaults to [NotificationHelper.scheduleNotificationAt] in production.
/// Replaceable in tests to capture scheduled entries without hitting the OS.
/*
typedef ScheduleNotificationFn =
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required DateTime dateTime,
      String? payload,
    });

/// Signature for cancelling a batch of notification ids.
typedef CancelNotificationsFn = Future<void> Function(Iterable<int> ids);

class PrayerTimesReminderService {
  // Stable notification IDs — exposed for testing.
  static const int fajrId = 9001;
  static const int dhuhrId = 9002;
  static const int asrId = 9003;
  static const int maghribId = 9004;
  static const int ishaId = 9005;

  static const int fajrTomorrowId = fajrId + 100;
  static const int dhuhrTomorrowId = dhuhrId + 100;
  static const int asrTomorrowId = asrId + 100;
  static const int maghribTomorrowId = maghribId + 100;
  static const int ishaTomorrowId = ishaId + 100;

  /// Injectable scheduler — uses [NotificationHelper] by default.
  final ScheduleNotificationFn _schedule;
  final CancelNotificationsFn _cancel;

  PrayerTimesReminderService({
    ScheduleNotificationFn? scheduleFn,
    CancelNotificationsFn? cancelFn,
  }) : _schedule = scheduleFn ?? _defaultSchedule,
       _cancel = cancelFn ?? _defaultCancel;

  /// Default scheduling implementation that delegates to [NotificationHelper].
  static Future<void> _defaultSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    await NotificationHelper.scheduleNotificationAt(
      id: id,
      title: title,
      body: body,
      dateTime: dateTime,
      payload: payload,
    );
  }

  /// Default cancel implementation that delegates to [NotificationHelper].
  static Future<void> _defaultCancel(Iterable<int> ids) async {
    for (final id in ids) {
      await NotificationHelper.cancelNotification(id);
    }
  }

  /// Convenience method: calculate today + tomorrow prayer times and schedule
  /// all notifications in one call. Safe to call from [main] at app startup.
  ///
  /// [asrMethod] — the juristic method the user has chosen; defaults to
  /// [AsrMethod.shafi] when not provided.
  Future<void> scheduleFromNow() async {
    try {
      final calculator = PrayerCalculator(
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 2.0,
      );

      final now = DateTime.now();
      final todayTimes = calculator.calculate(now);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final tomorrowTimes = calculator.calculate(tomorrow);

      log('[PrayerReminders] Scheduling from app startup…');
      await syncPrayerReminders(
        todayTimes: todayTimes,
        tomorrowTimes: tomorrowTimes,
        now: now,
      );
    } catch (e) {
      log('[PrayerReminders] scheduleFromNow failed: $e');
    }
  }

  Future<void> syncPrayerReminders({
    required PrayerTimes todayTimes,
    required PrayerTimes tomorrowTimes,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();

    final schedules = <PrayerSchedule>[
      ..._buildSchedulesForPrayer(
        todayId: fajrId,
        tomorrowId: fajrTomorrowId,
        prayerName: PrayerName.fajr,
        //todayPrayerTime: todayTimes.fajr,
                todayPrayerTime: DateTime.now().add(const Duration(minutes: 1)),

        tomorrowPrayerTime: tomorrowTimes.fajr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: dhuhrId,
        tomorrowId: dhuhrTomorrowId,
        prayerName: PrayerName.dhuhr,
        todayPrayerTime: DateTime.now().add(const Duration(minutes: 2)),
        tomorrowPrayerTime: tomorrowTimes.dhuhr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: asrId,
        tomorrowId: asrTomorrowId,
        prayerName: PrayerName.asr,
        todayPrayerTime: DateTime.now().add(const Duration(minutes: 3)),
        tomorrowPrayerTime: tomorrowTimes.asr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: maghribId,
        tomorrowId: maghribTomorrowId,
        prayerName: PrayerName.maghrib,
        todayPrayerTime: DateTime.now().add(const Duration(minutes: 4)),
        tomorrowPrayerTime: tomorrowTimes.maghrib,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: ishaId,
        tomorrowId: ishaTomorrowId,
        prayerName: PrayerName.isha,
        todayPrayerTime: DateTime.now().add(const Duration(minutes: 5)),
        tomorrowPrayerTime: tomorrowTimes.isha,
        now: current,
      ),
    ];

    // Cancel then reschedule using stable IDs.
    try {
      await _cancel(const [
        fajrId,
        dhuhrId,
        asrId,
        maghribId,
        ishaId,
        fajrTomorrowId,
        dhuhrTomorrowId,
        asrTomorrowId,
        maghribTomorrowId,
        ishaTomorrowId,
      ]);

      log('[PrayerReminders] Scheduling ${schedules.length} notifications…');

      for (final schedule in schedules) {
        log(
          '[PrayerReminders] → ${schedule.arabicName} '
          '(id=${schedule.id}) at ${schedule.reminderTime}',
        );
        await _schedule(
          id: schedule.id,
          title: 'حان وقت الصلاة 🕌',
          body: 'حان الآن موعد صلاة ${schedule.arabicName}',
        //  dateTime: schedule.reminderTime,
        //This second line for testing to trigger immediately until we confirm scheduling works as expected. Will switch back to schedule.reminderTime after that.
                  dateTime: schedule.reminderTime,

          payload: 'prayer_times:${schedule.prayerName.name}',
        );
      }

      log('[PrayerReminders] All notifications scheduled successfully ✓');
    } catch (e) {
      // Don't crash UI, but log so we can diagnose permission/scheduling issues.
      log('[PrayerReminders] Failed to sync prayer reminders: $e');
    }
  }

  List<PrayerSchedule> _buildSchedulesForPrayer({
    required int todayId,
    required int tomorrowId,
    required PrayerName prayerName,
    required DateTime todayPrayerTime,
    required DateTime tomorrowPrayerTime,
    required DateTime now,
  }) {
    final arabicName = _arabicLabel(prayerName) ?? prayerName.name;
    final result = <PrayerSchedule>[];

    // Schedule for today if the prayer hasn't passed yet.
    if (todayPrayerTime.isAfter(now)) {
      result.add(
        PrayerSchedule(
          id: todayId,
          prayerName: prayerName,
          arabicName: arabicName,
          reminderTime: todayPrayerTime,
        ),
      );
    }

    // Always schedule tomorrow (it's always in the future).
    if (tomorrowPrayerTime.isAfter(now)) {
      result.add(
        PrayerSchedule(
          id: tomorrowId,
          prayerName: prayerName,
          arabicName: arabicName,
          reminderTime: tomorrowPrayerTime,
        ),
      );
    }

    return result;
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
}

/// A scheduled prayer notification entry.
/// Public so tests can inspect the schedule results.
class PrayerSchedule {
  final int id;
  final PrayerName prayerName;
  final String arabicName;
  final DateTime reminderTime;

  const PrayerSchedule({
    required this.id,
    required this.prayerName,
    required this.arabicName,
    required this.reminderTime,
  });
}

//
//test jira
*/