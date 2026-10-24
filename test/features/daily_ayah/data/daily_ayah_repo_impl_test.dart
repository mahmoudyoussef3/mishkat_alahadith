import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_catalog.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_reminder_datasource.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_widget_datasource.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/models/daily_ayah_notification.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/repos/daily_ayah_repo_impl.dart';

import '../../quran/quran_fakes.dart';
import '../daily_ayah_fakes.dart';

class _FakeWidgetDataSource implements DailyAyahWidgetDataSource {
  bool fail = false;
  final List<List<Map<String, Object>>> saved = [];

  @override
  Future<void> save(List<Map<String, Object>> entries) async {
    if (fail) throw StateError('widget unavailable');
    saved.add(entries);
  }
}

class _FakeReminderDataSource implements DailyAyahReminderDataSource {
  bool enabled = true;
  bool grantPermission = true;
  bool fail = false;
  final List<List<DailyAyahNotification>> scheduled = [];
  final List<bool> choices = [];
  int cancelCalls = 0;

  @override
  Future<bool> isEnabled() async {
    if (fail) throw StateError('prefs unavailable');
    return enabled;
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !grantPermission) return false;
    choices.add(enabled);
    return true;
  }

  @override
  Future<void> schedule(List<DailyAyahNotification> notifications) async {
    if (fail) throw StateError('plugin unavailable');
    scheduled.add(notifications);
  }

  @override
  Future<void> cancelAll() async {
    if (fail) throw StateError('plugin unavailable');
    cancelCalls++;
  }
}

void main() {
  late _FakeWidgetDataSource widget;
  late _FakeReminderDataSource reminders;
  late DailyAyahRepoImpl repo;

  setUp(() {
    widget = _FakeWidgetDataSource();
    reminders = _FakeReminderDataSource();
    repo = DailyAyahRepoImpl(widget, reminders);
  });

  test('serves the bundled catalog by default', () async {
    expect(dataOf(await repo.getCatalog()), DailyAyahCatalog.ayahs);
  });

  test('writes one widget entry per day, in day order', () async {
    final days = [
      dailyAyahOn(DateTime(2026, 10, 23)),
      dailyAyahOn(DateTime(2026, 10, 24)),
    ];

    final result = await repo.updateHomeWidget(days);

    expect(result, isA<ApiSuccess<void>>());
    final entries = widget.saved.single;
    expect(entries, hasLength(2));
    expect(entries.last['day'] as int, (entries.first['day'] as int) + 1);
  });

  test('a widget that cannot be written is a failure, not a crash', () async {
    widget.fail = true;

    final result = await repo.updateHomeWidget([
      dailyAyahOn(DateTime(2026, 10, 23)),
    ]);

    expect(result, isA<ApiFailure<void>>());
  });

  test('schedules one notification per reminder', () async {
    final fireAt = DateTime(2026, 10, 24, 8);

    await repo.scheduleReminders([
      (fireAt: fireAt, dailyAyah: dailyAyahOn(DateTime(2026, 10, 24))),
    ]);

    final notification = reminders.scheduled.single.single;
    expect(notification.fireAt, fireAt);
    expect(notification.title, 'آية اليوم');
  });

  test('a refused permission fails with a message saying so', () async {
    reminders.grantPermission = false;

    final result = await repo.setReminderEnabled(true);

    expect(
      (result as ApiFailure<void>).failure,
      isA<UnexpectedFailure>().having(
        (f) => f.message,
        'message',
        FailureMessages.notificationsDenied,
      ),
    );
    expect(reminders.choices, isEmpty);
  });

  test('turning it off needs no permission', () async {
    reminders.grantPermission = false;

    final result = await repo.setReminderEnabled(false);

    expect(result, isA<ApiSuccess<void>>());
    expect(reminders.choices, [false]);
  });

  test('a choice that cannot be read is a failure', () async {
    reminders.fail = true;

    expect(await repo.isReminderEnabled(), isA<ApiFailure<bool>>());
  });

  test('cancelling reaches the notifications', () async {
    await repo.cancelReminders();

    expect(reminders.cancelCalls, 1);
  });
}
