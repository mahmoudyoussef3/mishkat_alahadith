import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
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
  static const PrayerTimesCalculator _calculator = PrayerTimesCalculator();
  static const String _scheduleKey = 'prayer_notification_schedule';
  static const int _daysAhead = 366;

  static bool _bootstrapped = false;

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
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (!enabled) {
      await cancelAll();
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

    final refreshResult = await refreshSchedule();
    if (!refreshResult.success) {
      return refreshResult;
    }

    return const PrayerNotificationActionResult(
      success: true,
      message: 'تم تفعيل إشعارات مواقيت الصلاة',
    );
  }

  static Future<PrayerNotificationActionResult> refreshSchedule() async {
    try {
      if (!await isEnabled()) {
        return const PrayerNotificationActionResult(
          success: true,
          message: 'إشعارات مواقيت الصلاة غير مفعلة',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      final location = await _resolveLocation(prefs);
      final schedule = buildSchedule(location);

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

  static Future<PrayerNotificationActionResult> cancelAll() async {
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

  static List<PrayerNotificationScheduleEntry> buildSchedule(
    PrayerNotificationLocation location, {
    DateTime? currentTime,
    int daysAhead = _daysAhead,
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

      entries.addAll([
        _entryForPrayer(day, 'fajr', prayerTimes.fajr, PrayerNames.fajr),
        _entryForPrayer(day, 'dhuhr', prayerTimes.dhuhr, PrayerNames.dhuhr),
        _entryForPrayer(day, 'asr', prayerTimes.asr, PrayerNames.asr),
        _entryForPrayer(day, 'maghrib', prayerTimes.maghrib, PrayerNames.maghrib),
        _entryForPrayer(day, 'isha', prayerTimes.isha, PrayerNames.isha),
      ]);
    }

    return entries
        .where((entry) => entry.fireAt.isAfter(now))
        .toList(growable: false);
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

class PrayerNotificationScheduleEntry {
  final int id;
  final String prayerKey;
  final String prayerLabel;
  final String title;
  final String body;
  final DateTime fireAt;

  const PrayerNotificationScheduleEntry({
    required this.id,
    required this.prayerKey,
    required this.prayerLabel,
    required this.title,
    required this.body,
    required this.fireAt,
  });

  factory PrayerNotificationScheduleEntry.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationScheduleEntry(
      id: (json['id'] as num).toInt(),
      prayerKey: json['prayerKey'] as String,
      prayerLabel:
          json['prayerLabel'] as String? ?? json['prayerKey'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      fireAt: DateTime.fromMillisecondsSinceEpoch(
        (json['fireAtMillis'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerKey': prayerKey,
      'prayerLabel': prayerLabel,
      'title': title,
      'body': body,
      'fireAtMillis': fireAt.millisecondsSinceEpoch,
    };
  }
}
