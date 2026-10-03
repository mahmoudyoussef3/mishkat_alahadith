import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/helpers/date_extensions.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/daily_prayer_times.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/device_location.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_location.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/calculate_prayer_times_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_device_position_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_next_prayer_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_saved_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/refresh_prayer_home_widget_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/request_location_access_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/save_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/core/prayer/prayer_defaults.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  static const String _calculationFailedMessage = 'تعذر حساب مواقيت الصلاة';
  static const String _locationFailedMessage = 'تعذر الحصول على الموقع الحالي';

  final GetSavedPrayerLocationUseCase _getSavedLocation;
  final SavePrayerLocationUseCase _saveLocation;
  final CalculatePrayerTimesUseCase _calculatePrayerTimes;
  final GetNextPrayerUseCase _getNextPrayer;
  final RequestLocationAccessUseCase _requestLocationAccess;
  final GetDevicePositionUseCase _getDevicePosition;
  final RefreshPrayerHomeWidgetUseCase _refreshHomeWidget;
  final ReschedulePrayerNotificationsUseCase _rescheduleNotifications;

  PrayerTimesCubit(
    this._getSavedLocation,
    this._saveLocation,
    this._calculatePrayerTimes,
    this._getNextPrayer,
    this._requestLocationAccess,
    this._getDevicePosition,
    this._refreshHomeWidget,
    this._rescheduleNotifications,
  ) : super(PrayerTimesInitial());

  Timer? _ticker;
  PrayerLocation _currentLocation = PrayerLocation.defaultLocation;
  DailyPrayerTimes? _prayerTimes;
  DailyPrayerTimes? _tomorrowPrayerTimes;

  PrayerLocation get currentLocation => _currentLocation;

  Future<void> init() async {
    emit(PrayerTimesLoading());
    _currentLocation = await _getSavedLocation();
    if (isClosed) return;
    final times = _calculateFor(_currentLocation);
    if (times == null) {
      emit(PrayerTimesError(_calculationFailedMessage));
      return;
    }
    emit(_buildLoaded(DateTime.now(), times));
    _startTicker();
    unawaited(_refreshHomeWidget());
  }

  DailyPrayerTimes? _calculateFor(PrayerLocation location) {
    final now = DateTime.now();
    final today = _calculatePrayerTimes(location, now);
    final tomorrow = _calculatePrayerTimes(location, now.nextCalendarDay);
    if ((today, tomorrow) case (
      ApiSuccess(data: final todayTimes),
      ApiSuccess(data: final tomorrowTimes),
    )) {
      _prayerTimes = todayTimes;
      _tomorrowPrayerTimes = tomorrowTimes;
      return todayTimes;
    }
    return null;
  }

  Future<void> updateLocation(PrayerLocation location) async {
    emit(PrayerTimesLoading());
    _currentLocation = location;
    final saved = await _saveLocation(location);
    if (isClosed) return;
    if (saved case ApiFailure()) {
      emit(PrayerTimesError(_calculationFailedMessage));
      return;
    }

    final times = _calculateFor(location);
    if (times == null) {
      emit(PrayerTimesError(_calculationFailedMessage));
      return;
    }
    emit(_buildLoaded(DateTime.now(), times));

    _startTicker();
    await _refreshHomeWidget();
    unawaited(_rescheduleNotifications());
  }

  Future<void> useCurrentLocation() async {
    final accessResult = await _requestLocationAccess();
    if (isClosed) return;
    final LocationAccess access;
    switch (accessResult) {
      case ApiFailure():
        emit(PrayerTimesError(_locationFailedMessage));
        return;
      case ApiSuccess(:final data):
        access = data;
    }

    switch (access) {
      case LocationAccess.serviceDisabled:
        emit(PrayerTimesError('الرجاء تفعيل خدمات الموقع على جهازك'));
        return;
      case LocationAccess.denied:
        emit(PrayerTimesError('يجب السماح بالوصول إلى الموقع'));
        return;
      case LocationAccess.deniedForever:
        emit(
          PrayerTimesError(
            'تم رفض الوصول إلى الموقع بشكل دائم. الرجاء تفعيله من الإعدادات',
          ),
        );
        return;
      case LocationAccess.granted:
        break;
    }

    emit(PrayerTimesLoading());
    final position = await _getDevicePosition();
    if (isClosed) return;
    switch (position) {
      case ApiFailure():
        emit(PrayerTimesError(_locationFailedMessage));
      case ApiSuccess(data: final position):
        await updateLocation(
          PrayerLocation.currentDevice(
            latitude: position.latitude,
            longitude: position.longitude,
            utcOffset: DateTime.now().timeZoneOffset,
          ),
        );
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is! PrayerTimesLoaded) return;

      final now = DateTime.now();
      if (!_isSameDay(now, current.date)) {
        final newTimes = _calculateFor(_currentLocation);
        if (newTimes == null) {
          emit(PrayerTimesError(_calculationFailedMessage));
          return;
        }
        emit(_buildLoaded(now, newTimes));
        unawaited(_refreshHomeWidget());
        unawaited(_rescheduleNotifications());
        return;
      }

      final nextPrayer = _nextPrayerAt(now);
      if (nextPrayer == null) return;

      emit(
        current.copyWith(
          remaining: nextPrayer.time.difference(now),
          nextPrayerLabel: _arabicLabel(nextPrayer.key),
          nextPrayerTime: nextPrayer.time,
        ),
      );
    });
  }

  NextPrayer? _nextPrayerAt(DateTime now) {
    final today = _prayerTimes;
    final tomorrow = _tomorrowPrayerTimes;
    if (today == null || tomorrow == null) return null;

    return _getNextPrayer(today: today, tomorrow: tomorrow, now: now);
  }

  PrayerTimesLoaded _buildLoaded(DateTime date, DailyPrayerTimes times) {
    final now = DateTime.now();
    final nextPrayer = _nextPrayerAt(now);

    return PrayerTimesLoaded(
      date: DateTime(date.year, date.month, date.day),
      times: times,
      nextPrayerLabel: _arabicLabel(nextPrayer?.key),
      nextPrayerTime: nextPrayer?.time,
      remaining: nextPrayer?.time.difference(now),
    );
  }

  String? _arabicLabel(String? name) => PrayerNames.arabic(name);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
