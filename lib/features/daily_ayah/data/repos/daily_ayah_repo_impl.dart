import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/ayah_reference.dart';
import '../../domain/entities/daily_ayah.dart';
import '../../domain/repos/daily_ayah_repo.dart';
import '../datasources/daily_ayah_catalog.dart';
import '../datasources/daily_ayah_reminder_datasource.dart';
import '../datasources/daily_ayah_widget_datasource.dart';
import '../mappers/daily_ayah_mappers.dart';

class DailyAyahRepoImpl implements DailyAyahRepo {
  final DailyAyahWidgetDataSource _widget;
  final DailyAyahReminderDataSource _reminders;
  final List<AyahReference> _catalog;

  DailyAyahRepoImpl(
    this._widget,
    this._reminders, {
    List<AyahReference> catalog = DailyAyahCatalog.ayahs,
  }) : _catalog = catalog;

  @override
  Future<ApiResult<List<AyahReference>>> getCatalog() async =>
      ApiResult.success(_catalog);

  @override
  Future<ApiResult<void>> updateHomeWidget(List<DailyAyah> ayahs) =>
      guardApiCall(
        () => _widget.save([for (final a in ayahs) a.toWidgetEntry()]),
      );

  @override
  Future<ApiResult<void>> scheduleReminders(
    List<DailyAyahReminder> reminders,
  ) => guardApiCall(
    () => _reminders.schedule([for (final r in reminders) r.toNotification()]),
  );

  @override
  Future<ApiResult<void>> cancelReminders() =>
      guardApiCall(_reminders.cancelAll);

  @override
  Future<ApiResult<bool>> isReminderEnabled() =>
      guardApiCall(_reminders.isEnabled);

  @override
  Future<ApiResult<void>> setReminderEnabled(bool enabled) async {
    final result = await guardApiCall(() => _reminders.setEnabled(enabled));
    return switch (result) {
      ApiSuccess(data: true) => const ApiResult.success(null),
      ApiSuccess(data: false) => const ApiResult.failure(
        UnexpectedFailure(FailureMessages.notificationsDenied),
      ),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  }
}
