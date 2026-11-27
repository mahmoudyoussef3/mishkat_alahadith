import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayahs_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';

import '../../quran/quran_fakes.dart';
import '../daily_ayah_fakes.dart';

void main() {
  final afterReminderTime = DateTime(2026, 10, 23, 9, 30);
  final beforeReminderTime = DateTime(2026, 10, 23, 6);

  SyncDailyAyahUseCase syncWith(
    FakeDailyAyahRepo repo, {
    DateTime? now,
    FakeQuranRepo? quranRepo,
    int daysAhead = 3,
  }) => SyncDailyAyahUseCase(
    GetDailyAyahsUseCase(repo, quranRepo ?? FakeQuranRepo()),
    repo,
    daysAhead: daysAhead,
    now: () => now ?? afterReminderTime,
  );

  test('hands the widget one ayah for each day ahead', () async {
    final repo = FakeDailyAyahRepo();

    final result = await syncWith(repo)();

    expect(result, isA<ApiSuccess<void>>());
    expect(repo.widgetUpdates.single.map((a) => a.day), [
      DateTime(2026, 10, 23),
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 25),
    ]);
  });

  test('schedules a morning reminder for each day not yet past', () async {
    final repo = FakeDailyAyahRepo();

    await syncWith(repo)();

    expect(repo.scheduled.single.map((r) => r.fireAt), [
      DateTime(2026, 10, 24, SyncDailyAyahUseCase.reminderHour),
      DateTime(2026, 10, 25, SyncDailyAyahUseCase.reminderHour),
    ]);
  });

  test("includes today's reminder before its hour", () async {
    final repo = FakeDailyAyahRepo();

    await syncWith(repo, now: beforeReminderTime)();

    expect(
      repo.scheduled.single.first.fireAt,
      DateTime(2026, 10, 23, SyncDailyAyahUseCase.reminderHour),
    );
  });

  test('each reminder carries the ayah of its own day', () async {
    final repo = FakeDailyAyahRepo();

    await syncWith(repo)();

    final reminders = repo.scheduled.single;
    final widgetDays = repo.widgetUpdates.single;
    for (final reminder in reminders) {
      final sameDay = widgetDays.firstWhere(
        (a) => a.day == reminder.dailyAyah.day,
      );
      expect(reminder.dailyAyah.ayah, sameDay.ayah);
    }
  });

  test('cancels the reminders when the reader turned them off', () async {
    final repo = FakeDailyAyahRepo(reminderEnabled: false);

    final result = await syncWith(repo)();

    expect(result, isA<ApiSuccess<void>>());
    expect(repo.scheduled, isEmpty);
    expect(repo.cancelCalls, 1);
    expect(repo.widgetUpdates, hasLength(1));
  });

  test('still schedules the reminders when the widget fails', () async {
    final repo = FakeDailyAyahRepo(failWidget: true);

    final result = await syncWith(repo)();

    expect(result, isA<ApiFailure<void>>());
    expect(repo.scheduled, hasLength(1));
  });

  test('still updates the widget when the reminders fail', () async {
    final repo = FakeDailyAyahRepo(failReminders: true);

    final result = await syncWith(repo)();

    expect(result, isA<ApiFailure<void>>());
    expect(repo.widgetUpdates, hasLength(1));
  });

  test('fails when the choice cannot be read, leaving reminders as they are',
      () async {
    final repo = FakeDailyAyahRepo(failEnabledRead: true);

    final result = await syncWith(repo)();

    expect(result, isA<ApiFailure<void>>());
    expect(repo.scheduled, isEmpty);
    expect(repo.cancelCalls, 0);
  });

  test('touches nothing when the ayahs cannot be read', () async {
    final repo = FakeDailyAyahRepo();

    final result = await syncWith(
      repo,
      quranRepo: FakeQuranRepo(failAyahs: true),
    )();

    expect(result, isA<ApiFailure<void>>());
    expect(repo.widgetUpdates, isEmpty);
    expect(repo.scheduled, isEmpty);
    expect(repo.cancelCalls, 0);
  });

  test('remindersFor leaves out a reminder due exactly now', () {
    final now = DateTime(2026, 10, 23, SyncDailyAyahUseCase.reminderHour);

    final reminders = SyncDailyAyahUseCase.remindersFor([
      dailyAyahOn(DateTime(2026, 10, 23)),
      dailyAyahOn(DateTime(2026, 10, 24)),
    ], now: now);

    expect(reminders.map((r) => r.dailyAyah.day), [DateTime(2026, 10, 24)]);
  });
}
