import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayah_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayahs_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/set_daily_ayah_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/presentation/logic/daily_ayah_reminder_cubit.dart';

import '../../quran/quran_fakes.dart';
import '../daily_ayah_fakes.dart';

DailyAyahReminderCubit _cubitWith(FakeDailyAyahRepo repo) =>
    DailyAyahReminderCubit(
      GetDailyAyahReminderEnabledUseCase(repo),
      SetDailyAyahReminderEnabledUseCase(
        repo,
        SyncDailyAyahUseCase(
          GetDailyAyahsUseCase(repo, FakeQuranRepo()),
          repo,
          daysAhead: 2,
          now: () => DateTime(2026, 10, 23, 6),
        ),
      ),
    );

void main() {
  test('load shows the saved choice', () async {
    final cubit = _cubitWith(FakeDailyAyahRepo());

    await cubit.load();

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.notice, isNull);
    await cubit.close();
  });

  test('load keeps the switch as it is when the choice cannot be read',
      () async {
    final cubit = _cubitWith(FakeDailyAyahRepo(failEnabledRead: true));

    await cubit.load();

    expect(cubit.state.enabled, isFalse);
    await cubit.close();
  });

  test('turning it on confirms with a notice', () async {
    final cubit = _cubitWith(FakeDailyAyahRepo(reminderEnabled: false));

    await cubit.toggle(true);

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.notice?.message, DailyAyahReminderCubit.enabledMessage);
    expect(cubit.state.notice?.isError, isFalse);
    await cubit.close();
  });

  test('turning it off confirms with a notice', () async {
    final cubit = _cubitWith(FakeDailyAyahRepo());
    await cubit.load();

    await cubit.toggle(false);

    expect(cubit.state.enabled, isFalse);
    expect(
      cubit.state.notice?.message,
      DailyAyahReminderCubit.disabledMessage,
    );
    await cubit.close();
  });

  test('a refused permission leaves it off and says why', () async {
    final cubit = _cubitWith(
      FakeDailyAyahRepo(reminderEnabled: false, permissionGranted: false),
    );

    await cubit.toggle(true);

    expect(cubit.state.enabled, isFalse);
    expect(cubit.state.notice?.isError, isTrue);
    expect(cubit.state.notice?.message, 'permission');
    await cubit.close();
  });

  test('a choice saved before scheduling failed shows as kept', () async {
    final repo = FakeDailyAyahRepo(reminderEnabled: false, failReminders: true);
    final cubit = _cubitWith(repo);

    await cubit.toggle(true);

    expect(repo.savedChoices, [true]);
    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.notice?.isError, isTrue);
    await cubit.close();
  });
}
