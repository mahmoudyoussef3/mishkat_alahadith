import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/entities/ayah_reference.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/entities/daily_ayah.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/repos/daily_ayah_repo.dart';

import '../quran/quran_fakes.dart';

/// References to the ayahs `quran_fakes.dart` holds.
const sampleCatalog = [
  AyahReference(1, 1),
  AyahReference(1, 2),
  AyahReference(2, 1),
  AyahReference(2, 142),
  AyahReference(4, 176),
];

DailyAyah dailyAyahOn(DateTime day) =>
    DailyAyah(day: day, ayah: hamd, surah: fatihah);

/// Records what reaches the widget and the notifications.
class FakeDailyAyahRepo implements DailyAyahRepo {
  List<AyahReference> catalog;
  bool reminderEnabled;
  bool failCatalog;
  bool failWidget;
  bool failReminders;
  bool failEnabledRead;

  /// Whether turning the reminder on is allowed, as a granted permission.
  bool permissionGranted;

  final List<List<DailyAyah>> widgetUpdates = [];
  final List<List<DailyAyahReminder>> scheduled = [];
  final List<bool> savedChoices = [];
  int cancelCalls = 0;

  FakeDailyAyahRepo({
    this.catalog = sampleCatalog,
    this.reminderEnabled = true,
    this.failCatalog = false,
    this.failWidget = false,
    this.failReminders = false,
    this.failEnabledRead = false,
    this.permissionGranted = true,
  });

  @override
  Future<ApiResult<List<AyahReference>>> getCatalog() async =>
      failCatalog
          ? const ApiResult.failure(CacheFailure('no catalog'))
          : ApiResult.success(catalog);

  @override
  Future<ApiResult<void>> updateHomeWidget(List<DailyAyah> ayahs) async {
    if (failWidget) return const ApiResult.failure(UnexpectedFailure('widget'));
    widgetUpdates.add(ayahs);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> scheduleReminders(
    List<DailyAyahReminder> reminders,
  ) async {
    if (failReminders) {
      return const ApiResult.failure(UnexpectedFailure('reminders'));
    }
    scheduled.add(reminders);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> cancelReminders() async {
    if (failReminders) {
      return const ApiResult.failure(UnexpectedFailure('reminders'));
    }
    cancelCalls++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<bool>> isReminderEnabled() async =>
      failEnabledRead
          ? const ApiResult.failure(CacheFailure('no choice'))
          : ApiResult.success(reminderEnabled);

  @override
  Future<ApiResult<void>> setReminderEnabled(bool enabled) async {
    if (enabled && !permissionGranted) {
      return const ApiResult.failure(UnexpectedFailure('permission'));
    }
    savedChoices.add(enabled);
    reminderEnabled = enabled;
    return const ApiResult.success(null);
  }
}
