import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_location_store.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_times_calculator.dart';
import 'package:mishkat_almasabih/core/services/prayer_times_home_widget_sync.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';

class PrayerNotificationScheduler {
  static const MethodChannel _channel = MethodChannel(
    'com.mishkat_almasabih.app/prayer_notifications',
  );

  static const String _userDisabledKey = 'prayer_notifications_user_disabled';
  static const String _preReminderEnabledKey = 'prayer_pre_reminder_enabled';
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();
  static const String _scheduleKey = 'prayer_notification_schedule';
  static const String _lastSyncKey = 'prayer_notification_last_sync';
  static const int _daysAhead = 366;

  /// Reminders before the adhan are kept to the coming month: the schedule is
  /// rebuilt every few hours anyway, and the native side rewrites the whole
  /// stored schedule each time an alarm fires.
  static const int _preReminderDaysAhead = 30;

  /// A reminder's id is its adhan's plus this: adhans are numbered by date in
  /// the low hundreds of millions, daily ayahs from 700 million, and pushes by
  /// the second they arrive, now well past 1.7 billion.
  static const int _preReminderIdOffset = 1000000000;

  static bool _bootstrapped = false;

  /// The last change to the schedule started, which the next one waits for.
  static Future<void> _pendingChange = Future.value();

  /// Runs schedule changes one at a time: one started while another is still
  /// resolving the location would otherwise undo it, such as a reschedule
  /// landing just after the reader turned prayer notifications off.
  static Future<T> _oneAtATime<T>(Future<T> Function() change) {
    final result = _pendingChange.then((_) => change());
    _pendingChange = result.then((_) {}, onError: (_) {});
    return result;
  }

  static Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    if (!await isEnabled()) return;
    await refreshSchedule();
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final userDisabled = prefs.getBool(_userDisabledKey) ?? false;
    if (userDisabled) return false;

    return Permission.notification.isGranted;
  }

  static Future<PrayerNotificationActionResult> setEnabled(
    bool enabled, {
    bool refresh = true,
  }) => _oneAtATime(() => _setEnabled(enabled, refresh: refresh));

  static Future<PrayerNotificationActionResult> _setEnabled(
    bool enabled, {
    required bool refresh,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!enabled) {
      await _cancelAll();
      await prefs.setBool(_userDisabledKey, true);
      return const PrayerNotificationActionResult(
        success: true,
        message: 'تم إيقاف إشعارات مواقيت الصلاة',
      );
    }

    final permissionResult = await _requestPermissions();
    if (!permissionResult.success) {
      return permissionResult;
    }

    await prefs.setBool(_userDisabledKey, false);

    if (!refresh) {
      return const PrayerNotificationActionResult(
        success: true,
        message: 'تم تفعيل إشعارات مواقيت الصلاة',
      );
    }

    final refreshResult = await _refreshSchedule();
    if (!refreshResult.success) {
      return refreshResult;
    }

    return const PrayerNotificationActionResult(
      success: true,
      message: 'تم تفعيل إشعارات مواقيت الصلاة',
    );
  }

  /// Whether the reader wants a reminder [PrayerDefaults.preReminderLead]
  /// before each adhan. Off until they turn it on, and only sent while
  /// [isEnabled].
  static Future<bool> isPreReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_preReminderEnabledKey) ?? false;
  }

  /// Saves the reader's choice and, while prayer notifications are on,
  /// reschedules them with or without the reminders.
  static Future<PrayerNotificationActionResult> setPreReminderEnabled(
    bool enabled,
  ) => _oneAtATime(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preReminderEnabledKey, enabled);

    // Scheduled along with the adhans, so applied once those are turned on.
    if (!await isEnabled()) {
      return const PrayerNotificationActionResult(
        success: true,
        message: 'تم حفظ التذكير قبل الصلاة',
      );
    }
    return _refreshSchedule();
  });

  static Future<PrayerNotificationActionResult> refreshSchedule() =>
      _oneAtATime(_refreshSchedule);

  static Future<PrayerNotificationActionResult> _refreshSchedule() async {
    try {
      if (!await isEnabled()) {
        return const PrayerNotificationActionResult(
          success: true,
          message: 'إشعارات مواقيت الصلاة غير مفعلة',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final location = await _resolveLocation(prefs);
      final schedule = buildSchedule(
        location,
        withPreReminders: await isPreReminderEnabled(),
      );

      if (schedule.isEmpty) {
        return const PrayerNotificationActionResult(
          success: false,
          message: 'لم يتم العثور على مواعيد صلاة قادمة لإعداد التنبيهات',
        );
      }

      await _persistLocation(prefs, location);
      await _persistSchedule(prefs, schedule);

      final scheduledCount = await _channel.invokeMethod<int>(
        'schedulePrayerNotifications',
        jsonEncode({'items': schedule.map((entry) => entry.toJson()).toList()}),
      );
      if (scheduledCount == null || scheduledCount <= 0) {
        throw StateError('Android did not schedule a prayer notification');
      }
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      await PrayerTimesHomeWidgetSync.refresh();

      return PrayerNotificationActionResult(
        success: true,
        message: 'تمت مزامنة إشعارات مواقيت الصلاة',
        scheduledCount: scheduledCount,
      );
    } catch (e, stackTrace) {
      log(
        'Error refreshing prayer notification schedule: $e',
        stackTrace: stackTrace,
      );
      return const PrayerNotificationActionResult(
        success: false,
        message: 'تعذر مزامنة إشعارات مواقيت الصلاة',
      );
    }
  }

  /// When the schedule was last written successfully, or null if never.
  static Future<DateTime?> lastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastSyncKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static Future<PrayerNotificationActionResult> cancelAll() =>
      _oneAtATime(_cancelAll);

  static Future<PrayerNotificationActionResult> _cancelAll() async {
    try {
      await _channel.invokeMethod('cancelPrayerNotifications');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scheduleKey);
      return const PrayerNotificationActionResult(
        success: true,
        message: 'تم إلغاء جميع إشعارات مواقيت الصلاة',
      );
    } catch (e, stackTrace) {
      log('Error canceling prayer notifications: $e', stackTrace: stackTrace);
      return const PrayerNotificationActionResult(
        success: false,
        message: 'تعذر إلغاء إشعارات مواقيت الصلاة',
      );
    }
  }

  static Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>(
        'hasExactAlarmPermission',
      );
      return result ?? false;
    } catch (e) {
      log('Exact alarm permission check failed: $e');
      return false;
    }
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>(
        'requestExactAlarmPermission',
      );
      return result ?? false;
    } catch (e) {
      log('Exact alarm permission request failed: $e');
      return false;
    }
  }

  static Future<bool> arePrayerNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;

    try {
      return await _channel.invokeMethod<bool>(
            'arePrayerNotificationsEnabled',
          ) ??
          false;
    } catch (e) {
      log('Prayer notification availability check failed: $e');
      return false;
    }
  }

  static Future<void> openPrayerNotificationSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('openPrayerNotificationSettings');
  }

  static Future<bool> hasBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>(
        'hasIgnoreBatteryOptimizations',
      );
      return result ?? false;
    } catch (e) {
      log('Battery optimization exemption check failed: $e');
      return false;
    }
  }

  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await _channel.invokeMethod<bool>('openBatteryOptimizationSettings');
    } catch (e) {
      log('Opening battery optimization settings failed: $e');
    }
  }

  static Future<PrayerNotificationActionResult> _requestPermissions() async {
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        return const PrayerNotificationActionResult(
          success: false,
          message: 'يرجى السماح بإشعارات التطبيق أولاً',
        );
      }

      if (!await arePrayerNotificationsEnabled()) {
        await openPrayerNotificationSettings();
        return const PrayerNotificationActionResult(
          success: false,
          message:
              'فعّل قناة إشعارات مواقيت الصلاة من إعدادات النظام ثم حاول مجدداً',
        );
      }

      final exactAlarmGranted = await hasExactAlarmPermission();
      if (!exactAlarmGranted) {
        await requestExactAlarmPermission();
      }
    }

    return const PrayerNotificationActionResult(
      success: true,
      message: 'تم منح الأذونات المطلوبة',
    );
  }

  static Future<PrayerNotificationLocation> _resolveLocation(
    SharedPreferences prefs,
  ) async {
    final storedLocation = PrayerLocationStore.read(prefs);
    if (storedLocation != null) {
      try {
        return PrayerNotificationLocation.fromJson(storedLocation);
      } catch (e) {
        log('Failed to parse stored prayer notification location: $e');
      }
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            ),
          );

          return PrayerNotificationLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: 'موقعك الحالي',
          );
        }
      }
    } catch (e) {
      log('Unable to resolve current location for prayer notifications: $e');
    }

    return PrayerNotificationLocation.defaultLocation;
  }

  /// The adhan of every prayer from [currentTime] on for [daysAhead] days,
  /// each preceded by its reminder when [withPreReminders], for the first
  /// [preReminderDaysAhead] days.
  static List<PrayerNotificationScheduleEntry> buildSchedule(
    PrayerNotificationLocation location, {
    DateTime? currentTime,
    int daysAhead = _daysAhead,
    bool withPreReminders = false,
    int preReminderDaysAhead = _preReminderDaysAhead,
  }) {
    final now = currentTime ?? DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final entries = <PrayerNotificationScheduleEntry>[];

    for (var offset = 0; offset < daysAhead; offset++) {
      final day = startOfToday.add(Duration(days: offset));
      final prayerTimes = _calculator.calculate(
        latitude: location.latitude,
        longitude: location.longitude,
        date: day,
      );

      final adhans = [
        _entryForPrayer(day, 'fajr', prayerTimes.fajr, PrayerNames.fajr),
        _entryForPrayer(day, 'dhuhr', prayerTimes.dhuhr, PrayerNames.dhuhr),
        _entryForPrayer(day, 'asr', prayerTimes.asr, PrayerNames.asr),
        _entryForPrayer(day, 'maghrib', prayerTimes.maghrib, PrayerNames.maghrib),
        _entryForPrayer(day, 'isha', prayerTimes.isha, PrayerNames.isha),
      ];
      final remind = withPreReminders && offset < preReminderDaysAhead;
      for (final adhan in adhans) {
        if (remind) entries.add(_preReminderFor(adhan));
        entries.add(adhan);
      }
    }

    return entries
        .where((entry) => entry.fireAt.isAfter(now))
        .toList(growable: false);
  }

  /// "اقتربت صلاة العصر", [PrayerDefaults.preReminderLead] before [adhan].
  static PrayerNotificationScheduleEntry _preReminderFor(
    PrayerNotificationScheduleEntry adhan,
  ) {
    const lead = PrayerDefaults.preReminderLead;
    final minutes = arabicCount(lead.inMinutes, ArabicNoun.minute);
    return PrayerNotificationScheduleEntry(
      id: _preReminderIdOffset + adhan.id,
      kind: PrayerNotificationKind.preReminder,
      prayerKey: adhan.prayerKey,
      prayerLabel: adhan.prayerLabel,
      title: 'اقتربت صلاة ${adhan.prayerLabel}',
      body: 'بعد $minutes يحين وقت الأذان',
      fireAt: adhan.fireAt.subtract(lead),
      prayerAt: adhan.fireAt,
    );
  }

  static PrayerNotificationScheduleEntry _entryForPrayer(
    DateTime day,
    String prayerKey,
    DateTime fireAt,
    String arabicLabel,
  ) {
    final dateKey = day.year * 10000 + day.month * 100 + day.day;
    final prayerIndex = switch (prayerKey) {
      'fajr' => 1,
      'dhuhr' => 2,
      'asr' => 3,
      'maghrib' => 4,
      'isha' => 5,
      _ => 0,
    };

    return PrayerNotificationScheduleEntry(
      id: dateKey * 10 + prayerIndex,
      prayerKey: prayerKey,
      prayerLabel: arabicLabel,
      title: 'تذكير صلاة $arabicLabel',
      body: 'حان الآن وقت صلاة $arabicLabel (${_formatPrayerTime(fireAt)}).',
      fireAt: fireAt,
    );
  }

  static String _formatPrayerTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static Future<void> _persistLocation(
    SharedPreferences prefs,
    PrayerNotificationLocation location,
  ) async {
    await PrayerLocationStore.write(prefs, location.toJson());
  }

  static Future<void> _persistSchedule(
    SharedPreferences prefs,
    List<PrayerNotificationScheduleEntry> schedule,
  ) async {
    await prefs.setString(
      _scheduleKey,
      jsonEncode(schedule.map((entry) => entry.toJson()).toList()),
    );
  }
}

class PrayerNotificationActionResult {
  final bool success;
  final String message;
  final int scheduledCount;

  const PrayerNotificationActionResult({
    required this.success,
    required this.message,
    this.scheduledCount = 0,
  });
}

class PrayerNotificationLocation {
  final double latitude;
  final double longitude;
  final String cityName;

  const PrayerNotificationLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  static const PrayerNotificationLocation defaultLocation =
      PrayerNotificationLocation(
        latitude: PrayerDefaults.latitude,
        longitude: PrayerDefaults.longitude,
        cityName: PrayerDefaults.cityName,
      );

  factory PrayerNotificationLocation.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? PrayerDefaults.latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? PrayerDefaults.longitude,
      cityName: json['cityName'] as String? ?? PrayerDefaults.cityName,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'cityName': cityName};
  }
}

/// What a scheduled prayer notification announces. The names are read by
/// the native schedulers, so they must not change.
enum PrayerNotificationKind {
  /// The prayer's time has come.
  adhan,

  /// The prayer's time is a few minutes away.
  preReminder,
}

class PrayerNotificationScheduleEntry {
  final int id;
  final PrayerNotificationKind kind;
  final String prayerKey;
  final String prayerLabel;
  final String title;
  final String body;
  final DateTime fireAt;

  /// When the prayer is due: [fireAt] for an adhan, later for a reminder.
  final DateTime prayerAt;

  const PrayerNotificationScheduleEntry({
    required this.id,
    this.kind = PrayerNotificationKind.adhan,
    required this.prayerKey,
    required this.prayerLabel,
    required this.title,
    required this.body,
    required this.fireAt,
    DateTime? prayerAt,
  }) : prayerAt = prayerAt ?? fireAt;

  factory PrayerNotificationScheduleEntry.fromJson(Map<String, dynamic> json) {
    final fireAt = DateTime.fromMillisecondsSinceEpoch(
      (json['fireAtMillis'] as num).toInt(),
    );
    final prayerAtMillis = json['prayerAtMillis'] as num?;
    return PrayerNotificationScheduleEntry(
      id: (json['id'] as num).toInt(),
      kind: PrayerNotificationKind.values.asNameMap()[json['kind']] ??
          PrayerNotificationKind.adhan,
      prayerKey: json['prayerKey'] as String,
      prayerLabel:
          json['prayerLabel'] as String? ?? json['prayerKey'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      fireAt: fireAt,
      prayerAt: prayerAtMillis == null
          ? fireAt
          : DateTime.fromMillisecondsSinceEpoch(prayerAtMillis.toInt()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'prayerKey': prayerKey,
      'prayerLabel': prayerLabel,
      'title': title,
      'body': body,
      'fireAtMillis': fireAt.millisecondsSinceEpoch,
      'prayerAtMillis': prayerAt.millisecondsSinceEpoch,
    };
  }
}
