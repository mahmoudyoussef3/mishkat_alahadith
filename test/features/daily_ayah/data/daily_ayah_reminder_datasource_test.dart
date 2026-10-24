import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/datasources/daily_ayah_reminder_datasource.dart';
import 'package:mishkat_almasabih/features/daily_ayah/data/models/daily_ayah_notification.dart';
import 'package:timezone/timezone.dart' as tz;

/// Keeps scheduled notifications in memory, and refuses past times as the
/// real plugin does.
class _FakePlugin implements FlutterLocalNotificationsPlugin {
  final Map<int, PendingNotificationRequest> pending = {};
  final List<tz.TZDateTime> scheduledAt = [];

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async =>
      pending.values.toList();

  @override
  Future<void> cancel(int id, {String? tag}) async => pending.remove(id);

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation
    uiLocalNotificationDateInterpretation,
    bool androidAllowWhileIdle = false,
    AndroidScheduleMode? androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      throw ArgumentError.value(scheduledDate, 'scheduledDate', 'is past');
    }
    scheduledAt.add(scheduledDate);
    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DailyAyahNotification _notification(int id, DateTime fireAt) =>
    DailyAyahNotification(
      id: id,
      title: 'آية اليوم',
      body: '﴿…﴾',
      subtitle: 'سورة الفاتحة · الآية ٢',
      payload: 'daily_ayah:2:1:1',
      fireAt: fireAt,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePlugin plugin;
  late DateTime now;
  late DailyAyahReminderDataSource dataSource;

  setUp(() {
    plugin = _FakePlugin();
    now = DateTime.now();
    dataSource = DailyAyahReminderDataSource(plugin: plugin, now: () => now);
  });

  test('schedules each notification at its time', () async {
    final tomorrow = now.add(const Duration(days: 1));

    await dataSource.schedule([_notification(1, tomorrow)]);

    expect(plugin.pending.keys, [1]);
    expect(plugin.scheduledAt.single.isAtSameMomentAs(tomorrow), isTrue);
  });

  test('skips one that fell due while the sync ran, keeping the rest',
      () async {
    final dueAlready = now.subtract(const Duration(seconds: 1));
    final tomorrow = now.add(const Duration(days: 1));

    await dataSource.schedule([
      _notification(1, dueAlready),
      _notification(2, tomorrow),
    ]);

    expect(plugin.pending.keys, [2]);
  });

  test('replaces the daily ayah notifications already pending', () async {
    plugin.pending[9] = const PendingNotificationRequest(
      9,
      'آية اليوم',
      'old',
      'daily_ayah:1:1:1',
    );

    await dataSource.schedule([
      _notification(1, now.add(const Duration(days: 1))),
    ]);

    expect(plugin.pending.keys, [1]);
  });

  test('cancelling leaves every other kind of notification alone', () async {
    plugin.pending
      ..[1] = const PendingNotificationRequest(
        1,
        'آية اليوم',
        '',
        'daily_ayah:2:1:1',
      )
      ..[2] = const PendingNotificationRequest(2, 'ورد', '', 'quran_wird')
      ..[3] = const PendingNotificationRequest(3, 'بلا', '', null);

    await dataSource.cancelAll();

    expect(plugin.pending.keys, unorderedEquals([2, 3]));
  });
}
