import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'dart:developer';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';

/// Signature for the function that actually schedules a single notification.
/// Defaults to [LocalNotification.scheduleOneTimeNotification] in production.
/// Replaceable in tests to capture scheduled entries without hitting the OS.
typedef ScheduleNotificationFn =
    Future<void> Function({
      required int id,
      required String channelId,
      required String channelName,
      required String title,
      required String body,
      required DateTime scheduledDate,
      String? payload,
    });

/// Signature for cancelling a batch of notification ids.
typedef CancelNotificationsFn = Future<void> Function(Iterable<int> ids);

class PrayerTimesReminderService {
  static const channelId = 'prayer_times_reminders';
  static const channelName = 'Prayer Times Reminders';

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

  /// Injectable scheduler — uses the real local-notification plugin by default.
  final ScheduleNotificationFn _schedule;
  final CancelNotificationsFn _cancel;

  PrayerTimesReminderService({
    ScheduleNotificationFn? scheduleFn,
    CancelNotificationsFn? cancelFn,
  }) : _schedule = scheduleFn ?? LocalNotification.scheduleOneTimeNotification,
       _cancel = cancelFn ?? LocalNotification.cancelReminders;

  /// Convenience method: calculate today + tomorrow prayer times and schedule
  /// all notifications in one call. Safe to call from [main] at app startup.
  ///
  /// [asrMethod] — the juristic method the user has chosen; defaults to
  /// [AsrMethod.standard] when not provided.
  Future<void> scheduleFromNow({
    AsrMethod asrMethod = AsrMethod.standard,
  }) async {
    try {
      final calculator = PrayerCalculator(
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 2.0,
        asrMethod: asrMethod,
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
        todayPrayerTime: todayTimes.fajr,
        tomorrowPrayerTime: tomorrowTimes.fajr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: dhuhrId,
        tomorrowId: dhuhrTomorrowId,
        prayerName: PrayerName.dhuhr,
        todayPrayerTime: todayTimes.dhuhr,
        tomorrowPrayerTime: tomorrowTimes.dhuhr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: asrId,
        tomorrowId: asrTomorrowId,
        prayerName: PrayerName.asr,
        todayPrayerTime: todayTimes.asr,
        tomorrowPrayerTime: tomorrowTimes.asr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: maghribId,
        tomorrowId: maghribTomorrowId,
        prayerName: PrayerName.maghrib,
        todayPrayerTime: todayTimes.maghrib,
        tomorrowPrayerTime: tomorrowTimes.maghrib,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: ishaId,
        tomorrowId: ishaTomorrowId,
        prayerName: PrayerName.isha,
        todayPrayerTime: todayTimes.isha,
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
          channelId: channelId,
          channelName: channelName,
          title: 'حان وقت الصلاة 🕌',
          body: 'حان الآن موعد صلاة ${schedule.arabicName}',
          scheduledDate: schedule.reminderTime,
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
