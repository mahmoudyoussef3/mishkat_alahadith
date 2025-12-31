import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';

class PrayerTimesReminderService {
  static const _channelId = 'prayer_times_reminders';
  static const _channelName = 'Prayer Times Reminders';

  // Stable IDs so re-scheduling overwrites previous day.
  static const int _fajrId = 9001;
  static const int _dhuhrId = 9002;
  static const int _asrId = 9003;
  static const int _maghribId = 9004;
  static const int _ishaId = 9005;

  static const _offset = Duration(minutes: 2);

  Future<void> syncPrayerReminders({
    required PrayerTimes todayTimes,
    required PrayerTimes tomorrowTimes,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();

    final schedules = <_PrayerSchedule?>[
      _buildSchedule(
        id: _fajrId,
        prayerName: PrayerName.fajr,
        todayPrayerTime: todayTimes.fajr,
        tomorrowPrayerTime: tomorrowTimes.fajr,
        now: current,
      ),
      _buildSchedule(
        id: _dhuhrId,
        prayerName: PrayerName.dhuhr,
        todayPrayerTime: todayTimes.dhuhr,
        tomorrowPrayerTime: tomorrowTimes.dhuhr,
        now: current,
      ),
      _buildSchedule(
        id: _asrId,
        prayerName: PrayerName.asr,
        todayPrayerTime: todayTimes.asr,
        tomorrowPrayerTime: tomorrowTimes.asr,
        now: current,
      ),
      _buildSchedule(
        id: _maghribId,
        prayerName: PrayerName.maghrib,
        todayPrayerTime: todayTimes.maghrib,
        tomorrowPrayerTime: tomorrowTimes.maghrib,
        now: current,
      ),
      _buildSchedule(
        id: _ishaId,
        prayerName: PrayerName.isha,
        todayPrayerTime: todayTimes.isha,
        tomorrowPrayerTime: tomorrowTimes.isha,
        now: current,
      ),
    ].whereType<_PrayerSchedule>().toList(growable: false);

    // Cancel then reschedule using stable IDs.
    try {
      await LocalNotification.cancelReminders(const [
        _fajrId,
        _dhuhrId,
        _asrId,
        _maghribId,
        _ishaId,
      ]);

      for (final schedule in schedules) {
        await LocalNotification.scheduleOneTimeNotification(
          id: schedule.id,
          channelId: _channelId,
          channelName: _channelName,
          title: 'تذكير الصلاة',
          body: 'تبقّى دقيقتان على صلاة ${schedule.arabicName}',
          scheduledDate: schedule.reminderTime,
          payload: 'prayer_times:${schedule.prayerName.name}',
        );
      }
    } catch (_) {
      // Intentionally swallow errors to avoid crashing UI.
    }
  }

  _PrayerSchedule? _buildSchedule({
    required int id,
    required PrayerName prayerName,
    required DateTime todayPrayerTime,
    required DateTime tomorrowPrayerTime,
    required DateTime now,
  }) {
    final todayReminder = todayPrayerTime.subtract(_offset);
    final reminderTime =
        todayReminder.isAfter(now)
            ? todayReminder
            : tomorrowPrayerTime.subtract(_offset);

    // If it still ended up in the past (device clock issues), skip.
    if (!reminderTime.isAfter(now)) return null;

    return _PrayerSchedule(
      id: id,
      prayerName: prayerName,
      arabicName: _arabicLabel(prayerName) ?? prayerName.name,
      reminderTime: reminderTime,
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
