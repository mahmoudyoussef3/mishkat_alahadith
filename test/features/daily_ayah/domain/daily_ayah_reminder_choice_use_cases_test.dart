import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayah_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayahs_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/set_daily_ayah_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';

import '../../quran/quran_fakes.dart';
import '../daily_ayah_fakes.dart';

void main() {
  SetDailyAyahReminderEnabledUseCase setEnabledWith(FakeDailyAyahRepo repo) =>
      SetDailyAyahReminderEnabledUseCase(
        repo,
        SyncDailyAyahUseCase(
          GetDailyAyahsUseCase(repo, FakeQuranRepo()),
          repo,
          daysAhead: 3,
          now: () => DateTime(2026, 10, 23, 6),
        ),
      );

  group('SetDailyAyahReminderEnabledUseCase', () {
    test('turning it on saves the choice and schedules the days ahead',
        () async {
      final repo = FakeDailyAyahRepo(reminderEnabled: false);

      final result = await setEnabledWith(repo)(true);

      expect(result, isA<ApiSuccess<void>>());
      expect(repo.savedChoices, [true]);
      expect(repo.scheduled.single, hasLength(3));
    });

    test('turning it off saves the choice and cancels what is pending',
        () async {
      final repo = FakeDailyAyahRepo();

      final result = await setEnabledWith(repo)(false);

      expect(result, isA<ApiSuccess<void>>());
      expect(repo.savedChoices, [false]);
      expect(repo.cancelCalls, 1);
      expect(repo.scheduled, isEmpty);
    });

    test('schedules nothing when the permission is refused', () async {
      final repo = FakeDailyAyahRepo(
        reminderEnabled: false,
        permissionGranted: false,
      );

      final result = await setEnabledWith(repo)(true);

      expect(result, isA<ApiFailure<void>>());
      expect(repo.savedChoices, isEmpty);
      expect(repo.scheduled, isEmpty);
    });
  });

  group('GetDailyAyahReminderEnabledUseCase', () {
    test('reports the saved choice', () async {
      final repo = FakeDailyAyahRepo(reminderEnabled: false);

      final result = await GetDailyAyahReminderEnabledUseCase(repo)();

      expect(dataOf(result), isFalse);
    });
  });
}
