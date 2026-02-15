import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'dart:developer';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';

class PrayerTimesReminderService {
  static const _channelId = 'prayer_times_reminders';
  static const _channelName = 'Prayer Times Reminders';

  static const int _fajrId = 9001;
  static const int _dhuhrId = 9002;
  static const int _asrId = 9003;
  static const int _maghribId = 9004;
  static const int _ishaId = 9005;

  // Reserve a second set of stable IDs for tomorrow's reminders.
  static const int _fajrTomorrowId = _fajrId + 100;
  static const int _dhuhrTomorrowId = _dhuhrId + 100;
  static const int _asrTomorrowId = _asrId + 100;
  static const int _maghribTomorrowId = _maghribId + 100;
  static const int _ishaTomorrowId = _ishaId + 100;

  /// Convenience method: calculate today + tomorrow prayer times and schedule
  /// all notifications in one call. Safe to call from [main] at app startup.
  Future<void> scheduleFromNow() async {
    try {
      final calculator = PrayerCalculator(
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 2.0,
        asrMethod: AsrMethod.hanafi,
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

    final schedules = <_PrayerSchedule>[
      ..._buildSchedulesForPrayer(
        todayId: _fajrId,
        tomorrowId: _fajrTomorrowId,
        prayerName: PrayerName.fajr,
        todayPrayerTime: todayTimes.fajr,
        tomorrowPrayerTime: tomorrowTimes.fajr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: _dhuhrId,
        tomorrowId: _dhuhrTomorrowId,
        prayerName: PrayerName.dhuhr,
        todayPrayerTime: todayTimes.dhuhr,
        tomorrowPrayerTime: tomorrowTimes.dhuhr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: _asrId,
        tomorrowId: _asrTomorrowId,
        prayerName: PrayerName.asr,
        todayPrayerTime: todayTimes.asr,
        tomorrowPrayerTime: tomorrowTimes.asr,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: _maghribId,
        tomorrowId: _maghribTomorrowId,
        prayerName: PrayerName.maghrib,
        todayPrayerTime: todayTimes.maghrib,
        tomorrowPrayerTime: tomorrowTimes.maghrib,
        now: current,
      ),
      ..._buildSchedulesForPrayer(
        todayId: _ishaId,
        tomorrowId: _ishaTomorrowId,
        prayerName: PrayerName.isha,
        todayPrayerTime: todayTimes.isha,
        tomorrowPrayerTime: tomorrowTimes.isha,
        now: current,
      ),
    ];

    // Cancel then reschedule using stable IDs.
    try {
      await LocalNotification.cancelReminders(const [
        _fajrId,
        _dhuhrId,
        _asrId,
        _maghribId,
        _ishaId,
        _fajrTomorrowId,
        _dhuhrTomorrowId,
        _asrTomorrowId,
        _maghribTomorrowId,
        _ishaTomorrowId,
      ]);

      log('[PrayerReminders] Scheduling ${schedules.length} notifications…');

      for (final schedule in schedules) {
        log(
          '[PrayerReminders] → ${schedule.arabicName} '
          '(id=${schedule.id}) at ${schedule.reminderTime}',
        );
        await LocalNotification.scheduleOneTimeNotification(
          id: schedule.id,
          channelId: _channelId,
          channelName: _channelName,
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

  List<_PrayerSchedule> _buildSchedulesForPrayer({
    required int todayId,
    required int tomorrowId,
    required PrayerName prayerName,
    required DateTime todayPrayerTime,
    required DateTime tomorrowPrayerTime,
    required DateTime now,
  }) {
    final arabicName = _arabicLabel(prayerName) ?? prayerName.name;
    final result = <_PrayerSchedule>[];

    // Schedule for today if the prayer hasn't passed yet.
    if (todayPrayerTime.isAfter(now)) {
      result.add(
        _PrayerSchedule(
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
        _PrayerSchedule(
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

class _PrayerSchedule {
  final int id;
  final PrayerName prayerName;
  final String arabicName;
  final DateTime reminderTime;

  const _PrayerSchedule({
    required this.id,
    required this.prayerName,
    required this.arabicName,
    required this.reminderTime,
  });
}
