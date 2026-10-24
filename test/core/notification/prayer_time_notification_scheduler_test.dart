import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/notification/prayer_time_notification_scheduler.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_location_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const MethodChannel _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// Mocks the permission_handler platform channel so `Permission.notification`
/// resolves to [granted] without touching a real device/OS permission.
void _mockNotificationPermission(bool granted) {
  TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .setMockMethodCallHandler(_permissionChannel, (call) async {
        switch (call.method) {
          case 'checkPermissionStatus':
            // PermissionStatus.granted == 1, PermissionStatus.denied == 0.
            return granted ? 1 : 0;
          default:
            return null;
        }
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(_permissionChannel, null);
  });

  group('PrayerNotificationScheduler.isEnabled', () {
    test(
      'is true by default (no toggle) once OS permission is granted',
      () async {
        SharedPreferences.setMockInitialValues({});
        _mockNotificationPermission(true);

        expect(await PrayerNotificationScheduler.isEnabled(), isTrue);
      },
    );

    test('is false when the OS notification permission is not granted', () async {
      SharedPreferences.setMockInitialValues({});
      _mockNotificationPermission(false);

      expect(await PrayerNotificationScheduler.isEnabled(), isFalse);
    });

    test(
      'is false when the user explicitly disabled it, even with permission',
      () async {
        SharedPreferences.setMockInitialValues({
          'prayer_notifications_user_disabled': true,
        });
        _mockNotificationPermission(true);

        expect(await PrayerNotificationScheduler.isEnabled(), isFalse);
      },
    );
  });

  group('PrayerNotificationScheduler.buildSchedule', () {
    test('creates five unique future prayer reminders for each full day', () {
      final now = DateTime(2026, 1, 15);

      final schedule = PrayerNotificationScheduler.buildSchedule(
        PrayerNotificationLocation.defaultLocation,
        currentTime: now,
        daysAhead: 2,
      );

      expect(schedule, hasLength(10));
      expect(schedule.map((entry) => entry.id).toSet(), hasLength(10));
      expect(schedule.every((entry) => entry.fireAt.isAfter(now)), isTrue);
      expect(schedule.map((entry) => entry.prayerKey).toSet(), {
        'fajr',
        'dhuhr',
        'asr',
        'maghrib',
        'isha',
      });
    });

    test('serialization preserves the alarm delivery timestamp', () {
      final entry = PrayerNotificationScheduleEntry(
        id: 123,
        prayerKey: 'fajr',
        prayerLabel: 'الفجر',
        title: 'تذكير صلاة الفجر',
        body: 'حان الآن وقت صلاة الفجر.',
        fireAt: DateTime.fromMillisecondsSinceEpoch(1768446000000),
      );

      final restored = PrayerNotificationScheduleEntry.fromJson(entry.toJson());

      expect(restored.id, entry.id);
      expect(restored.prayerKey, entry.prayerKey);
      expect(restored.fireAt, entry.fireAt);
    });

    test('adds no reminders before the adhan unless asked to', () {
      final schedule = PrayerNotificationScheduler.buildSchedule(
        PrayerNotificationLocation.defaultLocation,
        currentTime: DateTime(2026, 1, 15),
        daysAhead: 1,
      );

      expect(
        schedule.every((entry) => entry.kind == PrayerNotificationKind.adhan),
        isTrue,
      );
    });

    test('precedes every adhan by a reminder the lead time earlier', () {
      final schedule = PrayerNotificationScheduler.buildSchedule(
        PrayerNotificationLocation.defaultLocation,
        currentTime: DateTime(2026, 1, 15),
        daysAhead: 2,
        withPreReminders: true,
      );

      final adhans = schedule.where(
        (entry) => entry.kind == PrayerNotificationKind.adhan,
      );
      final reminders = schedule.where(
        (entry) => entry.kind == PrayerNotificationKind.preReminder,
      );
      expect(adhans, hasLength(10));
      expect(reminders, hasLength(10));
      expect(schedule.map((entry) => entry.id).toSet(), hasLength(20));
      for (final adhan in adhans) {
        final reminder = reminders.singleWhere(
          (entry) => entry.prayerAt == adhan.fireAt,
        );
        expect(
          adhan.fireAt.difference(reminder.fireAt),
          PrayerDefaults.preReminderLead,
        );
        expect(reminder.prayerKey, adhan.prayerKey);
        expect(reminder.title, 'اقتربت صلاة ${adhan.prayerLabel}');
        expect(reminder.body, 'بعد ٣ دقائق يحين وقت الأذان');
      }
    });

    test('keeps reminders to the days asked for', () {
      final schedule = PrayerNotificationScheduler.buildSchedule(
        PrayerNotificationLocation.defaultLocation,
        currentTime: DateTime(2026, 1, 15),
        daysAhead: 2,
        withPreReminders: true,
        preReminderDaysAhead: 1,
      );

      final reminders = schedule.where(
        (entry) => entry.kind == PrayerNotificationKind.preReminder,
      );
      expect(reminders, hasLength(5));
      expect(
        reminders.every((entry) => entry.fireAt.day == 15),
        isTrue,
      );
    });

    test('keeps an adhan whose reminder time has already passed', () {
      final firstFajr =
          PrayerNotificationScheduler.buildSchedule(
            PrayerNotificationLocation.defaultLocation,
            currentTime: DateTime(2026, 1, 15),
            daysAhead: 1,
          ).first.fireAt;

      final schedule = PrayerNotificationScheduler.buildSchedule(
        PrayerNotificationLocation.defaultLocation,
        currentTime: firstFajr.subtract(const Duration(minutes: 1)),
        daysAhead: 1,
        withPreReminders: true,
      );

      expect(schedule.first.kind, PrayerNotificationKind.adhan);
      expect(schedule.first.fireAt, firstFajr);
      expect(schedule, hasLength(9));
    });

    test('serialization preserves a reminder\'s kind and prayer time', () {
      final prayerAt = DateTime.fromMillisecondsSinceEpoch(1768446000000);
      final entry = PrayerNotificationScheduleEntry(
        id: 1000000123,
        kind: PrayerNotificationKind.preReminder,
        prayerKey: 'fajr',
        prayerLabel: 'الفجر',
        title: 'اقتربت صلاة الفجر',
        body: 'بعد ٣ دقائق يحين وقت الأذان',
        fireAt: prayerAt.subtract(const Duration(minutes: 3)),
        prayerAt: prayerAt,
      );

      final json = entry.toJson();
      final restored = PrayerNotificationScheduleEntry.fromJson(json);

      expect(json['kind'], 'preReminder');
      expect(restored.kind, PrayerNotificationKind.preReminder);
      expect(restored.prayerAt, prayerAt);
      expect(restored.fireAt, entry.fireAt);
    });

    test('reads an entry saved before reminders existed as an adhan', () {
      final restored = PrayerNotificationScheduleEntry.fromJson({
        'id': 123,
        'prayerKey': 'fajr',
        'prayerLabel': 'الفجر',
        'title': 'تذكير صلاة الفجر',
        'body': 'حان الآن وقت صلاة الفجر.',
        'fireAtMillis': 1768446000000,
      });

      expect(restored.kind, PrayerNotificationKind.adhan);
      expect(restored.prayerAt, restored.fireAt);
    });
  });

  group('PrayerNotificationScheduler changes', () {
    const prayerChannel = MethodChannel(
      'com.mishkat_almasabih.app/prayer_notifications',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(prayerChannel, null));

    test(
      'turning prayer notifications off waits for a reschedule in flight',
      () async {
        SharedPreferences.setMockInitialValues({
          PrayerLocationStore.key: jsonEncode(
            PrayerNotificationLocation.defaultLocation.toJson(),
          ),
        });
        _mockNotificationPermission(true);
        final calls = <String>[];
        messenger.setMockMethodCallHandler(prayerChannel, (call) async {
          calls.add(call.method);
          return call.method == 'schedulePrayerNotifications' ? 1 : true;
        });

        // Started together, as when the reader flips both switches quickly.
        await (
          PrayerNotificationScheduler.setPreReminderEnabled(true),
          PrayerNotificationScheduler.setEnabled(false),
        ).wait;

        expect(calls, [
          'schedulePrayerNotifications',
          'cancelPrayerNotifications',
        ]);
      },
    );
  });

  group('PrayerNotificationScheduler pre-reminder choice', () {
    test('is off until the reader turns it on', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await PrayerNotificationScheduler.isPreReminderEnabled(), isFalse);
    });

    test('is saved while prayer notifications are off', () async {
      SharedPreferences.setMockInitialValues({
        'prayer_notifications_user_disabled': true,
      });
      _mockNotificationPermission(true);

      final result = await PrayerNotificationScheduler.setPreReminderEnabled(
        true,
      );

      expect(result.success, isTrue);
      expect(await PrayerNotificationScheduler.isPreReminderEnabled(), isTrue);
    });
  });
}
