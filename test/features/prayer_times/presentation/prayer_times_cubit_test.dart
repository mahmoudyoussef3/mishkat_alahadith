import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_location.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/repos/prayer_notifications_repo.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/repos/prayer_times_repo.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/calculate_prayer_times_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_device_position_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_next_prayer_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_previous_prayer_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_saved_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/refresh_prayer_home_widget_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/request_location_access_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/save_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/prayer_times_cubit.dart';

/// A repo whose prayer-time calculation always fails.
class _FailingCalculationRepo extends Fake implements PrayerTimesRepo {
  @override
  Future<PrayerLocation> getSavedLocation() async =>
      PrayerLocation.defaultLocation;

  @override
  Future<ApiResult<void>> saveLocation(PrayerLocation location) async =>
      const ApiResult.success(null);

  @override
  ApiResult<DailyPrayerTimes> calculatePrayerTimes(
    PrayerLocation location,
    DateTime date,
  ) => const ApiResult.failure(UnexpectedFailure());

  @override
  Future<void> refreshHomeWidget() async {}
}

/// A repo that gives every day the same clock times on that date.
class _WorkingRepo extends _FailingCalculationRepo {
  @override
  ApiResult<DailyPrayerTimes> calculatePrayerTimes(
    PrayerLocation location,
    DateTime date,
  ) {
    DateTime at(int hour, int minute) =>
        DateTime(date.year, date.month, date.day, hour, minute);
    return ApiResult.success(
      DailyPrayerTimes(
        fajr: at(4, 24),
        sunrise: at(5, 49),
        dhuhr: at(11, 43),
        asr: at(15, 7),
        maghrib: at(17, 37),
        isha: at(18, 54),
      ),
    );
  }
}

class _UnusedNotificationsRepo extends Fake
    implements PrayerNotificationsRepo {}

PrayerTimesCubit _cubit([PrayerTimesRepo? calculating]) {
  final repo = calculating ?? _FailingCalculationRepo();
  return PrayerTimesCubit(
    GetSavedPrayerLocationUseCase(repo),
    SavePrayerLocationUseCase(repo),
    CalculatePrayerTimesUseCase(repo),
    GetNextPrayerUseCase(),
    RequestLocationAccessUseCase(repo),
    GetDevicePositionUseCase(repo),
    RefreshPrayerHomeWidgetUseCase(repo),
    ReschedulePrayerNotificationsUseCase(_UnusedNotificationsRepo()),
    GetPreviousPrayerUseCase(),
  );
}

void main() {
  test(
    'init shows an error, not a stuck spinner, when calculation fails',
    () async {
      final cubit = _cubit();

      await cubit.init();

      expect(cubit.state, isA<PrayerTimesError>());
      await cubit.close();
    },
  );

  test('updateLocation shows an error when calculation fails', () async {
    final cubit = _cubit();

    await cubit.updateLocation(PrayerLocation.defaultLocation);

    expect(cubit.state, isA<PrayerTimesError>());
    await cubit.close();
  });

  group('browsing days', () {
    late PrayerTimesCubit cubit;

    setUp(() async {
      cubit = _cubit(_WorkingRepo());
      await cubit.init();
    });

    tearDown(() => cubit.close());

    PrayerTimesLoaded loaded() => cubit.state as PrayerTimesLoaded;

    test('starts on today', () {
      expect(loaded().isShowingToday, isTrue);
      expect(loaded().previousPrayerLabel, isNotNull);
    });

    test('the next day lists that day\'s times and keeps today\'s countdown', () {
      final today = loaded().date;

      cubit.showAdjacentDay(1);

      expect(loaded().isShowingToday, isFalse);
      expect(loaded().selectedDate, DateTime(today.year, today.month, today.day + 1));
      expect(loaded().selectedTimes.fajr.day, loaded().selectedDate.day);
      expect(loaded().date, today);
    });

    test('showToday returns from another day', () {
      cubit.showAdjacentDay(-3);

      cubit.showToday();

      expect(loaded().isShowingToday, isTrue);
    });
  });
}
